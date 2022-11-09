<#-- @formatter:off -->
<#include "mcitems.ftl">
<#include "procedures.java.ftl">
<#include "triggers.java.ftl">

package ${package}.item;

import net.minecraft.world.entity.ai.attributes.Attributes;

<#if data.toolType == "Pickaxe" || data.toolType == "Axe" || data.toolType == "Sword" || data.toolType == "Spade" 
		|| data.toolType == "Hoe" || data.toolType == "Shears" || data.toolType == "MultiTool">
public class ${name}Item extends ${data.toolType?replace("Spade", "Shovel")?replace("MultiTool", "Tiered")}Item {
	public ${name}Item () {
		super(<#if data.toolType == "Pickaxe" || data.toolType == "Axe" || data.toolType == "Sword" || data.toolType == "Spade" 
				|| data.toolType == "Hoe" || data.toolType == "MultiTool">
			<#if data.harvestLevel == 100>Tiers.WOOD,<#elseif data.harvestLevel == 101>Tiers.STONE,<#elseif data.harvestLevel == 102>Tiers.GOLD,<#elseif data.harvestLevel == 103>Tiers.IRON,<#elseif data.harvestLevel == 104>Tiers.DIAMOND,<#elseif data.harvestLevel == 105>Tiers.NETHERITE,
			<#else>
			new Tier() {
				public int getUses() {
					return ${data.usageCount};
				}

   				public float getSpeed() {
					return ${data.efficiency}f;
				}

   				public float getAttackDamageBonus() {
					return ${data.damageVsEntity - 2}f;
				}

   				public int getLevel() {
					return ${data.harvestLevel};
				}

   				public int getEnchantmentValue() {
					return ${data.enchantability};
				}

   				public Ingredient getRepairIngredient() {
					<#if data.repairItems?has_content>
					return Ingredient.of(
						<#list data.repairItems as repairItem>
						${mappedMCItemToItemStackCode(repairItem,1)}<#sep>,
						</#list>
					);
					<#else>
					return Ingredient.EMPTY;
					</#if>
				}
			},
			<#/if>

			<#if data.toolType!="MultiTool">
				<#if data.toolType=="Sword">3<#elseif data.toolType=="Hoe">0<#else>1</#if>,${data.attackSpeed - 4}f,
			</#if>

				new Item.Properties()
			 	.tab(${data.creativeTab})
			 	<#if data.immuneToFire>
			 	.fireResistant()
			 	</#if>
		<#elseif data.toolType=="Shears">
			new Item.Properties()
				.tab(${data.creativeTab})
				.durability(${data.usageCount})
				<#if data.immuneToFire>
				.fireResistant()
				</#if>
		</#if>);
	}

	<#if data.toolType=="Shears">
		@Override public int getEnchantmentValue() {
    	    return ${data.enchantability};
    	}

    	@Override public float getDestroySpeed(ItemStack stack, BlockState blockstate) {
    		return ${data.efficiency}f;
    	}
	<#elseif data.toolType=="MultiTool">
		@Override public boolean isCorrectToolForDrops(BlockState blockstate) {
			int tier = ${data.harvestLevel};
			if (tier < 3 && blockstate.is(BlockTags.NEEDS_DIAMOND_TOOL)) {
				return false;
			} else if (tier < 2 && blockstate.is(BlockTags.NEEDS_IRON_TOOL)) {
				return false;
			} else {
				return tier < 1 && blockstate.is(BlockTags.NEEDS_STONE_TOOL) ? false : (
								blockstate.is(BlockTags.MINEABLE_WITH_AXE) ||
								blockstate.is(BlockTags.MINEABLE_WITH_HOE) ||
								blockstate.is(BlockTags.MINEABLE_WITH_PICKAXE) ||
								blockstate.is(BlockTags.MINEABLE_WITH_SHOVEL)
						);
			}
		}

		@Override public boolean canPerformAction(ItemStack stack, ToolAction toolAction) {
			return ToolActions.DEFAULT_AXE_ACTIONS.contains(toolAction) ||
					ToolActions.DEFAULT_HOE_ACTIONS.contains(toolAction) ||
					ToolActions.DEFAULT_SHOVEL_ACTIONS.contains(toolAction) ||
					ToolActions.DEFAULT_PICKAXE_ACTIONS.contains(toolAction) ||
					ToolActions.DEFAULT_SWORD_ACTIONS.contains(toolAction);
		}

		@Override public float getDestroySpeed(ItemStack itemstack, BlockState blockstate) {
			return ${data.efficiency}f;
		}

		@Override public Multimap<Attribute, AttributeModifier> getDefaultAttributeModifiers(EquipmentSlot equipmentSlot) {
			if (equipmentSlot == EquipmentSlot.MAINHAND) {
				ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = ImmutableMultimap.builder();
				builder.putAll(super.getDefaultAttributeModifiers(equipmentSlot));
				builder.put(Attributes.ATTACK_DAMAGE, new AttributeModifier(BASE_ATTACK_DAMAGE_UUID, "Tool modifier", ${data.damageVsEntity - 2}f, AttributeModifier.Operation.ADDITION));
				builder.put(Attributes.ATTACK_SPEED, new AttributeModifier(BASE_ATTACK_SPEED_UUID, "Tool modifier", ${data.attackSpeed - 4}, AttributeModifier.Operation.ADDITION));
				return builder.build();
			}

			return super.getDefaultAttributeModifiers(equipmentSlot);
		}
    </#if>

	<#if data.toolType=="MultiTool">
		<@onBlockDestroyedWith data.onBlockDestroyedWithTool, true/>

		<@onEntityHitWith data.onEntityHitWith, true/>
	<#else>
		<@onBlockDestroyedWith data.onBlockDestroyedWithTool/>

		<@onEntityHitWith data.onEntityHitWith/>
    </#if>

    <@onRightClickedInAir data.onRightClickedInAir/>

	<@commonMethods/>

}
<#elseif data.toolType=="Special">
public class ${name}Item extends Item {

    public ${name}Item() {
	    super(new Item.Properties()
		    .tab(${data.creativeTab})
			.durability(${data.usageCount})
			<#if data.immuneToFire>
			.fireResistant()
			</#if>
		);
	}

	@Override public float getDestroySpeed(ItemStack itemstack, BlockState blockstate) {
    	return List.of(
			<#list data.blocksAffected as restrictionBlock>
			${mappedBlockToBlock(restrictionBlock)}<#sep>,
			</#list>
		).contains(blockstate.getBlock()) ? ${data.efficiency}f : 1;
	}

	<@onBlockDestroyedWith data.onBlockDestroyedWithTool, true/>

	<@onEntityHitWith data.onEntityHitWith, true/>
	
	<@onRightClickedInAir data.onRightClickedInAir/>

	@Override public int getEnchantmentValue() {
		return ${data.enchantability};
	}

	@Override public Multimap<Attribute, AttributeModifier> getDefaultAttributeModifiers(EquipmentSlot equipmentSlot) {
		if (equipmentSlot == EquipmentSlot.MAINHAND) {
			ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = ImmutableMultimap.builder();
			builder.putAll(super.getDefaultAttributeModifiers(equipmentSlot));
			builder.put(Attributes.ATTACK_DAMAGE, new AttributeModifier(BASE_ATTACK_DAMAGE_UUID, "Tool modifier", ${data.damageVsEntity - 2}f, AttributeModifier.Operation.ADDITION));
			builder.put(Attributes.ATTACK_SPEED, new AttributeModifier(BASE_ATTACK_SPEED_UUID, "Tool modifier", ${data.attackSpeed - 4}, AttributeModifier.Operation.ADDITION));
			return builder.build();
		}

   	   return super.getDefaultAttributeModifiers(equipmentSlot);
   	}

    <@commonMethods/>
}
<#elseif data.toolType=="Fishing rod">
public class ${name}Item extends FishingRodItem {

	public ${name}Item() {
		super(new Item.Properties()
			.tab(${data.creativeTab})
			.durability(${data.usageCount})
			<#if data.immuneToFire>
			.fireResistant()
			</#if>
		);
	}

	<#if data.repairItems?has_content>
	@Override public boolean isValidRepairItem(ItemStack itemstack, ItemStack repairitem) {
		return List.of(
			<#list data.repairItems as repairItem>
				${mappedMCItemToItem(repairItem)}<#sep>,
				</#list>
		).contains(repairitem.getItem());
	}
	</#if>

	@Override public int getEnchantmentValue() {
		return ${data.enchantability};
	}

	<@onBlockDestroyedWith data.onBlockDestroyedWithTool/>

	<@onEntityHitWith data.onEntityHitWith/>
    
	@Override public InteractionResultHolder<ItemStack> use(Level world, Player entity, InteractionHand hand) {
		ItemStack itemstack = entity.getItemInHand(hand);
		if (entity.fishing != null) {
			if (!world.isClientSide()) {
				itemstack.hurtAndBreak(entity.fishing.retrieve(itemstack), entity, i -> i.broadcastBreakEvent(hand));
			}
			world.playSound(null, entity.getX(), entity.getY(), entity.getZ(), SoundEvents.FISHING_BOBBER_RETRIEVE, SoundSource.NEUTRAL, 1, 0.4f / (world.getRandom().nextFloat() * 0.4f + 0.8f));
			world.gameEvent(entity, GameEvent.FISHING_ROD_REEL_IN, entity);
		} else {
			world.playSound(null, entity.getX(), entity.getY(), entity.getZ(), SoundEvents.FISHING_BOBBER_THROW, SoundSource.NEUTRAL, 0.5f, 0.4f / (world.getRandom().nextFloat() * 0.4f + 0.8f));
			if (!world.isClientSide()) {
				int k = EnchantmentHelper.getFishingSpeedBonus(itemstack);
				int j = EnchantmentHelper.getFishingLuckBonus(itemstack);
				world.addFreshEntity(new FishingHook(entity, world, j, k) {

					@Override public boolean shouldStopFishing(Player player) {
						if (!player.isRemoved() && player.isAlive() &&
								(player.getMainHandItem().is(${JavaModName}Items.${data.getModElement().getRegistryNameUpper()}.get()) ||
								player.getOffhandItem().is(${JavaModName}Items.${data.getModElement().getRegistryNameUpper()}.get()))
								&& !(this.distanceToSqr(player) > 1024)) {
							return false;
						} else {
							this.discard();
							return true;
						}
					}

				});
			}

			entity.awardStat(Stats.ITEM_USED.get(this));
			world.gameEvent(entity, GameEvent.FISHING_ROD_CAST, entity);
		}
		
		<#if hasProcedure(data.onRightClickedInAir)>
			<@procedureCode data.onRightClickedInAir, {
				"x": "entity.getX()",
				"y": "entity.getY()",
				"z": "entity.getZ()",
				"world": "world",
				"entity": "entity",
				"itemstack": "itemstack"
			}/>
		</#if>

		return InteractionResultHolder.sidedSuccess(itemstack, world.isClientSide());
	}

    <@commonMethods/>
}
</#if>

<#macro commonMethods>
	<#if data.stayInGridWhenCrafting>
        @Override public boolean hasContainerItem(ItemStack stack) {
        	return true;
        }

        <#if data.damageOnCrafting && data.usageCount != 0>
        	@Override public ItemStack getContainerItem(ItemStack itemstack) {
        		ItemStack retval = new ItemStack(this);
        		retval.setDamageValue(itemstack.getDamageValue() + 1);
        		if(retval.getDamageValue() >= retval.getMaxDamage()) {
        			return ItemStack.EMPTY;
        		}
        		return retval;
        	}

        	@Override public boolean isRepairable(ItemStack itemstack) {
        		return false;
        	}
        <#else>
        	@Override public ItemStack getContainerItem(ItemStack itemstack) {
        		return new ItemStack(this);
        	}

        	<#if data.usageCount != 0>
        	    @Override public boolean isRepairable(ItemStack itemstack) {
        		    return false;
        	    }
        	</#if>
        </#if>
    </#if>

    <#if data.specialInfo?has_content>
    	@Override public void appendHoverText(ItemStack itemstack, Level world, List<Component> list, TooltipFlag flag) {
    		super.appendHoverText(itemstack, world, list, flag);
    		<#list data.specialInfo as entry>
    		list.add(new TextComponent("${JavaConventions.escapeStringForJava(entry)}"));
    		</#list>
    	}
    </#if>

    <@onItemUsedOnBlock data.onRightClickedOnBlock/>

	<@onCrafted data.onCrafted/>

	<@onEntitySwing data.onEntitySwing/>

	<@onStoppedUsing data.onStoppedUsing/>

	<@onItemTick data.onItemInUseTick, data.onItemInInventoryTick/>

    <#if data.hasGlow>
	<@hasGlow data.glowCondition/>
    </#if>
</#macro>
<#-- @formatter:on -->
