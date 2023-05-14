// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.19;

import {SafeMath} from "../../dependencies/openzeppelin/contracts/SafeMath.sol";
import {DistributionTypes} from '../libraries/types/DistributionTypes.sol';
import {IDistributionManager} from '../../interfaces/IDistributionManager.sol';
import {IAToken} from '../../interfaces/IAToken.sol';
import {IERC20Detailed} from "../../dependencies/openzeppelin/contracts/IERC20Detailed.sol";

/**
 * @title DistributionManager
 * @notice Accounting contract to manage multiple staking distributions
 * @author Aave and VMEX
 **/
contract DistributionManager is IDistributionManager {
  using SafeMath for uint256;

  //atoken address to distribution data
  mapping(address => DistributionTypes.IncentivizedAsset) internal _incentivizedAssets;

  address[] internal _allIncentivizedAssets;
  address[] internal _allRewards;

  address public immutable EMISSION_MANAGER;

  constructor(address emissionManager) {
    EMISSION_MANAGER = emissionManager;
  }

  /**
   * @dev Configures the distribution of rewards for a list of assets
   * @param config The list of configurations to apply
   **/
  function configureRewards(RewardConfig[] calldata config) external override {
    require(msg.sender == EMISSION_MANAGER, 'ONLY_EMISSION_MANAGER');
    for (uint256 i = 0; i < config.length; i++) {
      DistributionTypes.IncentivizedAsset storage incentivizedAsset = _incentivizedAssets[
        config[i].incentivizedAsset
      ];
      DistributionTypes.Reward storage reward = incentivizedAsset.rewardData[config[i].reward];

      if (incentivizedAsset.decimals == 0) {
        // this incentivized asset has not been introduced yet
        _allIncentivizedAssets.push(config[i].incentivizedAsset);
      }
      if (reward.lastUpdateTimestamp == 0) {
        // this reward has not been introduced yet
        incentivizedAsset.rewardList[incentivizedAsset.numRewards] = config[i].reward;
        incentivizedAsset.numRewards++;
        _allRewards.push(config[i].reward);
      }

      incentivizedAsset.decimals = IERC20Detailed(config[i].incentivizedAsset).decimals();
      uint256 totalSupply = IAToken(config[i].incentivizedAsset).scaledTotalSupply();
      (uint256 index, ) = _updateReward(reward, totalSupply, incentivizedAsset.decimals);

      reward.emissionPerSecond = config[i].emissionPerSecond;
      reward.endTimestamp = config[i].endTimestamp;

      emit RewardConfigUpdated(
        config[i].incentivizedAsset,
        config[i].reward,
        config[i].emissionPerSecond,
        config[i].endTimestamp,
        index
      );
    }
  }

  /**
   * @dev Updates the reward's index and lastUpdateTimestamp
   **/
  function _updateReward(
    DistributionTypes.Reward storage reward,
    uint256 totalSupply,
    uint8 decimals
  ) internal returns (uint256, bool) {
    bool updated;
    uint256 newIndex = _getAssetIndex(reward, totalSupply, decimals);

    if (newIndex != reward.index) {
      reward.index = newIndex;
      updated = true;
    }
    reward.lastUpdateTimestamp = uint128(block.timestamp);

    return (newIndex, updated);
  }

  /**
   * @dev Updates the user's index and lastUpdateTimestamp for a specific reward
   **/
  function _updateUser(
    DistributionTypes.Reward storage reward,
    address user,
    uint256 balance,
    uint8 decimals
  ) internal returns (uint256, bool) {
    bool updated;
    uint256 accrued;
    uint256 userIndex = reward.users[user].index;

    if (userIndex != reward.index) {
      if (balance != 0) {
        accrued = _getReward(balance, reward.index, userIndex, decimals);
        reward.users[user].accrued += accrued;
      }
      reward.users[user].index = reward.index;
      updated = true;
    }

    return (accrued, updated);
  }

  /**
   * @dev Updates an incentivized asset's index and lastUpdateTimestamp
   **/
  function _updateIncentivizedAsset(
    address asset,
    address user,
    uint256 userBalance,
    uint256 assetSupply
  ) internal {
    assert(userBalance <= assetSupply); // will catch cases such as if userBalance and assetSupply were flipped
    DistributionTypes.IncentivizedAsset storage incentivizedAsset = _incentivizedAssets[asset];

    if (incentivizedAsset.numRewards == 0) {
      return;
    }

    for (uint128 i = 0; i < incentivizedAsset.numRewards; i++) {
      address rewardAddress = incentivizedAsset.rewardList[i];

      DistributionTypes.Reward storage reward = incentivizedAsset.rewardData[rewardAddress];

      (uint256 newIndex, bool rewardUpdated) = _updateReward(
        reward,
        assetSupply,
        incentivizedAsset.decimals
      );
      (uint256 rewardAccrued, bool userUpdated) = _updateUser(
        reward,
        user,
        userBalance,
        incentivizedAsset.decimals
      );

      if (rewardUpdated || userUpdated) {
        emit RewardAccrued(asset, rewardAddress, user, newIndex, rewardAccrued);
      }
    }
  }

  /**
   * @dev Updates the index of all incentivized assets the user passes in.
   **/
  function _batchUpdate(
    address user,
    DistributionTypes.UserAssetState[] memory userAssets
  ) internal {
    for (uint256 i = 0; i < userAssets.length; i++) {
      _updateIncentivizedAsset(
        userAssets[i].asset,
        user,
        userAssets[i].userBalance,
        userAssets[i].totalSupply
      );
    }
  }

  /**
   * @dev Calculates the user's rewards on a reward distribution
   * @param principalUserBalance Amount staked by the user on a reward
   * @param rewardIndex The index of the reward
   * @param userIndex The index of the user
   * @return The reward calculation
   **/
  function _getReward(
    uint256 principalUserBalance,
    uint256 rewardIndex,
    uint256 userIndex,
    uint8 decimals
  ) internal pure returns (uint256) {
    return principalUserBalance.mul(rewardIndex.sub(userIndex)).div(10 ** decimals);
  }

  /**
   * @dev Calculates the next index of a specific reward
   * @param reward Storage pointer to the distribution reward config
   * @param totalSupply The total supply of the reward asset
   * @param decimals The decimals of reward asset
   * @return The new index.
   **/
  function _getAssetIndex(
    DistributionTypes.Reward storage reward,
    uint256 totalSupply,
    uint8 decimals
  ) internal view returns (uint256) {
    if (
      reward.emissionPerSecond == 0 ||
      totalSupply == 0 ||
      reward.lastUpdateTimestamp == block.timestamp ||
      reward.lastUpdateTimestamp >= reward.endTimestamp
    ) {
      return reward.index;
    }

    uint256 currentTimestamp = block.timestamp > reward.endTimestamp
      ? reward.endTimestamp
      : block.timestamp;
    uint256 timeDelta = currentTimestamp.sub(reward.lastUpdateTimestamp);
    return
      uint256(reward.emissionPerSecond).mul(timeDelta).mul(10 ** decimals).div(totalSupply).add(
        reward.index
      );
  }

  /**
   * @dev Returns the index of an user on a specific reward streaming for a specific incentivized asset
   * @param user Address of the user
   * @param incentivizedAsset The incentivized asset address
   * @param reward The reward address
   * @return The index
   **/
  function getUserRewardIndex(
    address user,
    address incentivizedAsset,
    address reward
  ) external view returns (uint256) {
    return _incentivizedAssets[incentivizedAsset].rewardData[reward].users[user].index;
  }

  /**
   * @dev Returns the data of a specific reward streaming for a specific incentivized asset
   * @param incentivizedAsset The incentivized asset address
   * @param reward The reward address
   * @return index The index of the reward
   * @return emissionsPerSecond The emissionsPerSecond of the reward
   * @return lastUpdateTimestamp The lastUpdateTimestamp of the reward
   * @return endTimestamp The endTimestamp of the reward
   **/
  function getRewardsData(
    address incentivizedAsset,
    address reward
  ) external view override returns (uint256, uint256, uint256, uint256) {
    return (
      _incentivizedAssets[incentivizedAsset].rewardData[reward].index,
      _incentivizedAssets[incentivizedAsset].rewardData[reward].emissionPerSecond,
      _incentivizedAssets[incentivizedAsset].rewardData[reward].lastUpdateTimestamp,
      _incentivizedAssets[incentivizedAsset].rewardData[reward].endTimestamp
    );
  }

  /**
   * @dev Returns a user's total accrued rewards for a specifc reward address
   * @param user The user's address
   * @param reward The reward address
   * @return total The total amount of accrued rewards
   **/
  function getAccruedRewards(
    address user,
    address reward
  ) external view override returns (uint256) {
    uint256 total;
    for (uint256 i = 0; i < _allIncentivizedAssets.length; i++) {
      total += _incentivizedAssets[_allIncentivizedAssets[i]]
        .rewardData[reward]
        .users[user]
        .accrued;
    }

    return total;
  }
}
