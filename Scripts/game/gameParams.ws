/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SDurabilityThreshold
{
	var thresholdMax : float;	
	var multiplier : float;		
	var difficulty : EDifficultyMode;
};


import class W3GameParams extends CObject
{
	private var dm : CDefinitionsManagerAccessor;					
	private var main : SCustomNode;									
	
	
	public const var BASE_ABILITY_TAG : name;																					
	public const var PASSIVE_BONUS_ABILITY_TAG : name;																			
		default BASE_ABILITY_TAG = 'base';
		default PASSIVE_BONUS_ABILITY_TAG = 'passive';
	private var forbiddenAttributes : array<name>;				
																
																
	public var GLOBAL_ENEMY_ABILITY : name;						
		default GLOBAL_ENEMY_ABILITY = 'all_NPC_ability';
	
	public var ENEMY_BONUS_PER_LEVEL : name;					
		default ENEMY_BONUS_PER_LEVEL = 'NPCLevelBonus';
		
	public var ENEMY_BONUS_FISTFIGHT_LOW : name;					
		default ENEMY_BONUS_FISTFIGHT_LOW = 'NPCLevelModFistFightLower';
	
	public var ENEMY_BONUS_FISTFIGHT_HIGH : name;					
		default ENEMY_BONUS_FISTFIGHT_HIGH = 'NPCLevelModFistFightHigher';
		
	public var ENEMY_BONUS_LOW : name;					
		default ENEMY_BONUS_LOW = 'NPCLevelBonusLow';
		
	public var ENEMY_BONUS_HIGH : name;					
		default ENEMY_BONUS_HIGH = 'NPCLevelBonusHigh';
		
	public var ENEMY_BONUS_DEADLY : name;					
		default ENEMY_BONUS_DEADLY = 'NPCLevelBonusDeadly';
		
	public var MONSTER_BONUS_PER_LEVEL : name;					
		default MONSTER_BONUS_PER_LEVEL = 'MonsterLevelBonus';
		
	public var MONSTER_BONUS_PER_LEVEL_GROUP : name;					
		default MONSTER_BONUS_PER_LEVEL_GROUP = 'MonsterLevelBonusGroup';
		
	public var MONSTER_BONUS_PER_LEVEL_ARMORED : name;					
		default MONSTER_BONUS_PER_LEVEL_ARMORED = 'MonsterLevelBonusArmored';
		
	public var MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED : name;					
		default MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED = 'MonsterLevelBonusGroupArmored';
		
	public var MONSTER_BONUS_LOW : name;						
		default MONSTER_BONUS_LOW = 'MonsterLevelBonusLow';
		
	public var MONSTER_BONUS_HIGH : name;						
		default MONSTER_BONUS_HIGH = 'MonsterLevelBonusHigh';
		
	public var MONSTER_BONUS_DEADLY : name;						
		default MONSTER_BONUS_DEADLY = 'MonsterLevelBonusDeadly';
	
	public var BOSS_NGP_BONUS : name;
		default BOSS_NGP_BONUS = 'BossNGPLevelBonus';
		
	public var GLOBAL_PLAYER_ABILITY : name;					
		default GLOBAL_PLAYER_ABILITY = 'all_PC_ability';
	
	public const var NOT_A_SKILL_ABILITY_TAG : name;			
		default NOT_A_SKILL_ABILITY_TAG = 'NotASkill';
	
	
	public const var ALCHEMY_COOKED_ITEM_TYPE_POTION, ALCHEMY_COOKED_ITEM_TYPE_BOMB, ALCHEMY_COOKED_ITEM_TYPE_OIL : string;		
	public const var OIL_ABILITY_TAG : name;																					
	public const var QUANTITY_INCREASED_BY_ALCHEMY_TABLE : int;
		default ALCHEMY_COOKED_ITEM_TYPE_POTION = "Potion";
		default ALCHEMY_COOKED_ITEM_TYPE_BOMB = "Bomb";
		default ALCHEMY_COOKED_ITEM_TYPE_OIL = "Oil";	 
		default	OIL_ABILITY_TAG = 'OilBonus';
		default QUANTITY_INCREASED_BY_ALCHEMY_TABLE = 1;
	
	
	public const var ATTACK_NAME_LIGHT, ATTACK_NAME_HEAVY, ATTACK_NAME_SUPERHEAVY, ATTACK_NAME_SPEED_BASED, ATTACK_NO_DAMAGE : name;		
		default ATTACK_NAME_LIGHT = 'attack_light';
		default ATTACK_NAME_HEAVY = 'attack_heavy';
		default ATTACK_NAME_SUPERHEAVY = 'attack_super_heavy';
		default ATTACK_NAME_SPEED_BASED = 'attack_speed_based';		
		default ATTACK_NO_DAMAGE = 'attack_no_damage';		
	
	
	public const var MAX_DYNAMICALLY_SPAWNED_BOATS : int;		
		default MAX_DYNAMICALLY_SPAWNED_BOATS = 5;
	
	
	public const var MAX_THROW_RANGE : float;					
	public const var UNDERWATER_THROW_RANGE : float;					
	public const var PROXIMITY_PETARD_IDLE_DETONATION_TIME : float;		
	public const var BOMB_THROW_DELAY : float;							
		default MAX_THROW_RANGE = 25.0;
		default UNDERWATER_THROW_RANGE = 5.0;
		default PROXIMITY_PETARD_IDLE_DETONATION_TIME = 10.0;
		default BOMB_THROW_DELAY = 2.f;
		
	
	public const var CONTAINER_DYNAMIC_DESTROY_TIMEOUT : int;	
		default CONTAINER_DYNAMIC_DESTROY_TIMEOUT = 900;
		
	
	public const var CRITICAL_HIT_CHANCE : name;					
	public const var CRITICAL_HIT_DAMAGE_BONUS : name;				
	public const var CRITICAL_HIT_REDUCTION : name;					
	public const var CRITICAL_HIT_FX : name;						
	public const var HEAD_SHOT_CRIT_CHANCE_BONUS : float;			
	public const var BACK_ATTACK_CRIT_CHANCE_BONUS : float;			
	
		default CRITICAL_HIT_CHANCE = 'critical_hit_chance';
		default CRITICAL_HIT_FX = 'critical_hit';
		default CRITICAL_HIT_DAMAGE_BONUS = 'critical_hit_damage_bonus';
		default CRITICAL_HIT_REDUCTION = 'critical_hit_damage_reduction';
		default HEAD_SHOT_CRIT_CHANCE_BONUS = 0.5;
		default BACK_ATTACK_CRIT_CHANCE_BONUS = 0.5;
	
	
	public const var DAMAGE_NAME_DIRECT, DAMAGE_NAME_PHYSICAL, DAMAGE_NAME_SILVER, DAMAGE_NAME_SLASHING, DAMAGE_NAME_PIERCING, DAMAGE_NAME_BLUDGEONING, DAMAGE_NAME_RENDING, DAMAGE_NAME_ELEMENTAL, DAMAGE_NAME_FIRE, DAMAGE_NAME_FORCE, DAMAGE_NAME_FROST, DAMAGE_NAME_POISON, DAMAGE_NAME_SHOCK, DAMAGE_NAME_MORALE, DAMAGE_NAME_STAMINA : name;
		default DAMAGE_NAME_DIRECT 		= 'DirectDamage';
		default DAMAGE_NAME_PHYSICAL 	= 'PhysicalDamage';
		default DAMAGE_NAME_SILVER 		= 'SilverDamage';
		default DAMAGE_NAME_SLASHING	= 'SlashingDamage';
		default DAMAGE_NAME_PIERCING 	= 'PiercingDamage';
		default DAMAGE_NAME_BLUDGEONING = 'BludgeoningDamage';
		default DAMAGE_NAME_RENDING	 	= 'RendingDamage';
		default DAMAGE_NAME_ELEMENTAL	= 'ElementalDamage';
		default DAMAGE_NAME_FIRE 		= 'FireDamage';
		default DAMAGE_NAME_FORCE 		= 'ForceDamage';
		default DAMAGE_NAME_FROST 		= 'FrostDamage';
		default DAMAGE_NAME_POISON 		= 'PoisonDamage';
		default DAMAGE_NAME_SHOCK 		= 'ShockDamage';
		default DAMAGE_NAME_MORALE 		= 'MoraleDamage';
		default DAMAGE_NAME_STAMINA 	= 'StaminaDamage';
		
	public const var FOCUS_DRAIN_PER_HIT : float;					
	public const var UNINTERRUPTED_HITS_CAMERA_EFFECT_REGULAR_ENEMY, UNINTERRUPTED_HITS_CAMERA_EFFECT_BIG_ENEMY : name;		
	public const var MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS 	: float;		
	public const var ARMOR_VALUE_NAME : name;
	public const var LOW_HEALTH_EFFECT_SHOW : float;				
	public const var UNDERWATER_CROSSBOW_DAMAGE_BONUS : float;					
	public const var UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP : float;				
	public const var ARCHER_DAMAGE_BONUS_NGP : float;				

		default MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS = 70;
		default ARMOR_VALUE_NAME = 'armor';		
		default UNDERWATER_CROSSBOW_DAMAGE_BONUS = 2;
		default UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP = 6;
		default ARCHER_DAMAGE_BONUS_NGP = 2;
		default UNINTERRUPTED_HITS_CAMERA_EFFECT_REGULAR_ENEMY = 'combat_radial_blur';
		default UNINTERRUPTED_HITS_CAMERA_EFFECT_BIG_ENEMY = 'combat_radial_blur_big';
		default FOCUS_DRAIN_PER_HIT = 0.02;
		default LOW_HEALTH_EFFECT_SHOW = 0.3;
	
	public const var IGNI_SPELL_POWER_MILT : float;
		default	IGNI_SPELL_POWER_MILT = 1.0f;
	
	public const var AARD_SPELL_POWER_MULT : float;
		default AARD_SPELL_POWER_MULT = 1.0f;
		
	public const var INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN : float;					
		default INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN = 15.f;
	
	
	public var DIFFICULTY_TAG_EASY, DIFFICULTY_TAG_MEDIUM, DIFFICULTY_TAG_HARD, DIFFICULTY_TAG_HARDCORE : name;			
	public var DIFFICULTY_TAG_DIFF_ABILITY : name;																		
	public var DIFFICULTY_HP_MULTIPLIER, DIFFICULTY_DMG_MULTIPLIER : name;												
	public var DIFFICULTY_TAG_IGNORE : name;																			
	
		default DIFFICULTY_TAG_DIFF_ABILITY = 'DifficultyModeAbility';		
		default DIFFICULTY_TAG_EASY			= 'Easy';
		default DIFFICULTY_TAG_MEDIUM		= 'Medium';
		default DIFFICULTY_TAG_HARD			= 'Hard';
		default DIFFICULTY_TAG_HARDCORE 	= 'Hardcore';
		default DIFFICULTY_HP_MULTIPLIER 	= 'health_final_multiplier';
		default DIFFICULTY_DMG_MULTIPLIER 	= 'damage_final_multiplier';
		default DIFFICULTY_TAG_IGNORE		= 'IgnoreDifficultyAbilities';
		
	
	public const var DISMEMBERMENT_ON_DEATH_CHANCE : int;				
		default DISMEMBERMENT_ON_DEATH_CHANCE = 30;
		
	
	public const var FINISHER_ON_DEATH_CHANCE : int;					
		default FINISHER_ON_DEATH_CHANCE = 30;		
	
	
	public const var DURABILITY_ARMOR_LOSE_CHANCE, DURABILITY_WEAPON_LOSE_CHANCE : int;			
	public const var DURABILITY_ARMOR_LOSE_VALUE : float;										
	private const var DURABILITY_WEAPON_LOSE_VALUE, DURABILITY_WEAPON_LOSE_VALUE_HARDCORE : float;
	public const var DURABILITY_ARMOR_CHEST_WEIGHT, DURABILITY_ARMOR_PANTS_WEIGHT, DURABILITY_ARMOR_BOOTS_WEIGHT, DURABILITY_ARMOR_GLOVES_WEIGHT, DURABILITY_ARMOR_MISS_WEIGHT : int; 
	protected var durabilityThresholdsWeapon, durabilityThresholdsArmor : array<SDurabilityThreshold>;					
	public const var TAG_REPAIR_CONSUMABLE_ARMOR, TAG_REPAIR_CONSUMABLE_STEEL, TAG_REPAIR_CONSUMABLE_SILVER : name;		
	public const var ITEM_DAMAGED_DURABILITY : int;												
	public var INTERACTIVE_REPAIR_OBJECT_MAX_DURS : array<int>;									
		
		default TAG_REPAIR_CONSUMABLE_ARMOR = 'RepairArmor';
		default TAG_REPAIR_CONSUMABLE_STEEL = 'RepairSteel';
		default TAG_REPAIR_CONSUMABLE_SILVER = 'RepairSilver';
		
		default ITEM_DAMAGED_DURABILITY = 50;
	
		default DURABILITY_ARMOR_LOSE_CHANCE = 100;
		default DURABILITY_WEAPON_LOSE_CHANCE = 100;
		default DURABILITY_ARMOR_LOSE_VALUE = 0.6;	
		default DURABILITY_WEAPON_LOSE_VALUE = 0.26; 
		default DURABILITY_WEAPON_LOSE_VALUE_HARDCORE = 0.1;
		
		
		default DURABILITY_ARMOR_MISS_WEIGHT = 10;
		default DURABILITY_ARMOR_CHEST_WEIGHT = 50;			
		default DURABILITY_ARMOR_BOOTS_WEIGHT = 15;
		default DURABILITY_ARMOR_PANTS_WEIGHT = 15;
		default DURABILITY_ARMOR_GLOVES_WEIGHT = 10;
	
	
	public const var CFM_SLOWDOWN_RATIO : float;					
		default CFM_SLOWDOWN_RATIO = 0.01;
	
	
	public const var LIGHT_HIT_FX, LIGHT_HIT_BACK_FX, LIGHT_HIT_PARRIED_FX, LIGHT_HIT_BACK_PARRIED_FX, HEAVY_HIT_FX, HEAVY_HIT_BACK_FX, HEAVY_HIT_PARRIED_FX, HEAVY_HIT_BACK_PARRIED_FX : name;
		default LIGHT_HIT_FX = 'light_hit';			
		default LIGHT_HIT_BACK_FX = 'light_hit_back';
		default LIGHT_HIT_PARRIED_FX = 'light_hit_parried';
		default LIGHT_HIT_BACK_PARRIED_FX = 'light_hit_back_parried';
		default HEAVY_HIT_FX = 'heavy_hit';
		default HEAVY_HIT_BACK_FX = 'heavy_hit_back';
		default HEAVY_HIT_PARRIED_FX = 'heavy_hit_parried';
		default HEAVY_HIT_BACK_PARRIED_FX = 'heavy_hit_back_parried';
		
	public const var LOW_HP_SHOW_LEVEL : float;							
		default LOW_HP_SHOW_LEVEL = 0.25;

	
	public const var TAG_ARMOR : name;								
	public const var TAG_ENCUMBRANCE_ITEM_FORCE_YES : name;			
	public const var TAG_ENCUMBRANCE_ITEM_FORCE_NO : name;			
	public const var TAG_ITEM_UPGRADEABLE : name;					
	public const var TAG_DONT_SHOW : name;							
	public const var TAG_DONT_SHOW_ONLY_IN_PLAYERS : name;			
	public const var TAG_ITEM_SINGLETON : name;						
	public const var TAG_INFINITE_AMMO : name;						
	public const var TAG_UNDERWATER_AMMO : name;					
	public const var TAG_GROUND_AMMO : name;	
	public const var TAG_ILLUSION_MEDALLION : name;
	public const var TAG_PLAYER_STEELSWORD : name;					
	public const var TAG_PLAYER_SILVERSWORD : name;					
	public const var TAG_INFINITE_USE : name;						
	private var ARMOR_MASTERWORK_ABILITIES 	: array<name>;			
	private var ARMOR_MAGICAL_ABILITIES 	: array<name>;			
	private var GLOVES_MASTERWORK_ABILITIES	: array<name>;			
	private var GLOVES_MAGICAL_ABILITIES 	: array<name>;			
	private var PANTS_MASTERWORK_ABILITIES	: array<name>;			
	private var PANTS_MAGICAL_ABILITIES 	: array<name>;			
	private var BOOTS_MASTERWORK_ABILITIES	: array<name>;			
	private var BOOTS_MAGICAL_ABILITIES 	: array<name>;			
	private var WEAPON_MASTERWORK_ABILITIES	: array<name>;			
	private var WEAPON_MAGICAL_ABILITIES 	: array<name>;			
	public const var ITEM_SET_TAG_BEAR, ITEM_SET_TAG_GRYPHON, ITEM_SET_TAG_LYNX, ITEM_SET_TAG_WOLF, ITEM_SET_TAG_RED_WOLF, ITEM_SET_TAG_VAMPIRE, ITEM_SET_TAG_VIPER, ITEM_SET_TAG_NETFLIX : name;		

	public const var BOUNCE_ARROWS_ABILITY : name;					
	public const var TAG_ALCHEMY_REFILL_ALCO : name;				
	public const var REPAIR_OBJECT_BONUS_ARMOR_ABILITY : name;		
	public const var REPAIR_OBJECT_BONUS_WEAPON_ABILITY : name;		
	public const var REPAIR_OBJECT_BONUS : name;					
	public const var CIRI_SWORD_NAME : name;
	public const var TAG_OFIR_SET : name;							
		
		default TAG_ARMOR = 'Armor';
		default TAG_ENCUMBRANCE_ITEM_FORCE_YES = 'EncumbranceOn';
		default TAG_ENCUMBRANCE_ITEM_FORCE_NO = 'EncumbranceOff';
		default TAG_ITEM_UPGRADEABLE = 'Upgradeable';
		default TAG_DONT_SHOW = 'NoShow';
		default TAG_DONT_SHOW_ONLY_IN_PLAYERS = 'NoShowInPlayersInventory';
		default TAG_ITEM_SINGLETON = 'SingletonItem';
		default TAG_INFINITE_AMMO = 'InfiniteAmmo';
		default TAG_UNDERWATER_AMMO = 'UnderwaterAmmo';
		default TAG_GROUND_AMMO = 'GroundAmmo';
		default TAG_ILLUSION_MEDALLION = 'IllusionMedallion';
		default TAG_PLAYER_STEELSWORD = 'PlayerSteelWeapon';
		default TAG_PLAYER_SILVERSWORD = 'PlayerSilverWeapon';
		default TAG_INFINITE_USE = 'InfiniteUse';
		default ITEM_SET_TAG_BEAR = 'BearSet';
		default ITEM_SET_TAG_GRYPHON = 'GryphonSet';
		default ITEM_SET_TAG_LYNX = 'LynxSet';
		default ITEM_SET_TAG_WOLF = 'WolfSet';
		default ITEM_SET_TAG_RED_WOLF = 'RedWolfSet';
		default ITEM_SET_TAG_VIPER = 'ViperSet';
		default ITEM_SET_TAG_VAMPIRE = 'VampireSet';

		default ITEM_SET_TAG_NETFLIX = 'NetflixSet';
		default BOUNCE_ARROWS_ABILITY = 'bounce_arrows';
		default TAG_ALCHEMY_REFILL_ALCO = 'StrongAlcohol';
		default REPAIR_OBJECT_BONUS_ARMOR_ABILITY = 'repair_object_armor_bonus';
		default REPAIR_OBJECT_BONUS_WEAPON_ABILITY = 'repair_object_weapon_bonus';
		default REPAIR_OBJECT_BONUS = 'repair_object_stat_bonus';
		default CIRI_SWORD_NAME = 'Zireael Sword';
		default TAG_OFIR_SET = 'Ofir';
	
	
	private var newGamePlusLevel : int;						
	private const var NEW_GAME_PLUS_LEVEL_ADD : int;		
	public const var NEW_GAME_PLUS_MIN_LEVEL : int;				
	public const var NEW_GAME_PLUS_EP1_MIN_LEVEL : int;			
		default NEW_GAME_PLUS_LEVEL_ADD = 0;
		default NEW_GAME_PLUS_MIN_LEVEL = 30;
		default NEW_GAME_PLUS_EP1_MIN_LEVEL = 30;
	
	
	public const var TAG_STEEL_OIL, TAG_SILVER_OIL : name;
		default TAG_STEEL_OIL = 'SteelOil';
		default TAG_SILVER_OIL = 'SilverOil';
	
	
	public const var HEAVY_STRIKE_COST_MULTIPLIER : float;								
	public const var PARRY_HALF_ANGLE : int;											
	public const var PARRY_STAGGER_REDUCE_DAMAGE_LARGE : float;							
	public const var PARRY_STAGGER_REDUCE_DAMAGE_SMALL : float;							
		default PARRY_HALF_ANGLE = 180;
		default HEAVY_STRIKE_COST_MULTIPLIER = 2.0;
		default PARRY_STAGGER_REDUCE_DAMAGE_LARGE = 0.6f;
		default PARRY_STAGGER_REDUCE_DAMAGE_SMALL = 0.3f;
		
	
	public const var POTION_QUICKSLOTS_COUNT : int;										
		default POTION_QUICKSLOTS_COUNT = 4;
	
	
	public const var ITEMS_REQUIRED_FOR_MINOR_SET_BONUS : int;
	public const var ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS : int;
	public const var ITEM_SET_TAG_BONUS					: name;
		default ITEMS_REQUIRED_FOR_MINOR_SET_BONUS = 3;
		default ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS = 6;
		default ITEM_SET_TAG_BONUS = 'SetBonusPiece';
	
	
	public const var TAG_STEEL_SOCKETABLE, TAG_SILVER_SOCKETABLE, TAG_ARMOR_SOCKETABLE, TAG_ABILITY_SOCKET : name;
		default TAG_STEEL_SOCKETABLE = 'SteelSocketable';							
		default TAG_SILVER_SOCKETABLE = 'SilverSocketable';							
		default TAG_ARMOR_SOCKETABLE = 'ArmorSocketable';							
		default TAG_ABILITY_SOCKET = 'Socket';										
		
	
	public const var STAMINA_COST_PARRY_ATTRIBUTE, STAMINA_COST_COUNTERATTACK_ATTRIBUTE, STAMINA_COST_EVADE_ATTRIBUTE, STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE, 
					 STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE, STAMINA_COST_HEAVY_ACTION_ATTRIBUTE, STAMINA_COST_LIGHT_ACTION_ATTRIBUTE, STAMINA_COST_DODGE_ATTRIBUTE,
					 STAMINA_COST_SPRINT_ATTRIBUTE, STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE, STAMINA_COST_JUMP_ATTRIBUTE, STAMINA_COST_USABLE_ITEM_ATTRIBUTE,
					 STAMINA_COST_DEFAULT, STAMINA_COST_PER_SEC_DEFAULT, STAMINA_COST_ROLL_ATTRIBUTE, STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE, STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE : name;
					 
	public const var STAMINA_DELAY_PARRY_ATTRIBUTE, STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE, STAMINA_DELAY_EVADE_ATTRIBUTE, STAMINA_DELAY_SWIMMING_ATTRIBUTE, 
					 STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE, STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE, STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE, STAMINA_DELAY_DODGE_ATTRIBUTE,
					 STAMINA_DELAY_SPRINT_ATTRIBUTE, STAMINA_DELAY_JUMP_ATTRIBUTE, STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE, STAMINA_DELAY_DEFAULT, STAMINA_DELAY_ROLL_ATTRIBUTE,
					 STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE, STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE: name;
					 
	public const var STAMINA_SEGMENT_SIZE : int;									
		
		default STAMINA_SEGMENT_SIZE = 10;
		
		default STAMINA_COST_DEFAULT = 'stamina_cost';
		default STAMINA_COST_PER_SEC_DEFAULT = 'stamina_cost_per_sec';
		default STAMINA_COST_LIGHT_ACTION_ATTRIBUTE = 'light_action_stamina_cost';
		default STAMINA_COST_HEAVY_ACTION_ATTRIBUTE = 'heavy_action_stamina_cost';
		default STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE = 'super_heavy_action_stamina_cost';
		default STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE = 'light_special_stamina_cost';
		default STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE = 'heavy_special_stamina_cost';
		default STAMINA_COST_PARRY_ATTRIBUTE = 'parry_stamina_cost';
		default STAMINA_COST_COUNTERATTACK_ATTRIBUTE = 'counter_stamina_cost';
		default STAMINA_COST_DODGE_ATTRIBUTE = 'dodge_stamina_cost';
		default STAMINA_COST_EVADE_ATTRIBUTE = 'evade_stamina_cost';
		default STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE = 'swimming_stamina_cost_per_sec';
		default STAMINA_COST_SPRINT_ATTRIBUTE = 'sprint_stamina_cost';
		default STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE = 'sprint_stamina_cost_per_sec';
		default STAMINA_COST_JUMP_ATTRIBUTE = 'jump_stamina_cost';
		default STAMINA_COST_USABLE_ITEM_ATTRIBUTE = 'usable_item_stamina_cost';
		default STAMINA_COST_ROLL_ATTRIBUTE = 'roll_stamina_cost';
	
		default STAMINA_DELAY_DEFAULT = 'stamina_delay';
		default STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE = 'light_action_stamina_delay';
		default STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE = 'heavy_action_stamina_delay';			 
		default STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE = 'super_heavy_action_stamina_delay';
		default STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE = 'light_special_stamina_delay';
		default STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE = 'heavy_special_stamina_delay';	
		default STAMINA_DELAY_PARRY_ATTRIBUTE = 'parry_stamina_delay';
		default STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE = 'counter_stamina_delay';
		default STAMINA_DELAY_DODGE_ATTRIBUTE = 'dodge_stamina_delay';
		default STAMINA_DELAY_EVADE_ATTRIBUTE = 'evade_stamina_delay';
		default STAMINA_DELAY_SWIMMING_ATTRIBUTE = 'swimming_stamina_delay';
		default STAMINA_DELAY_SPRINT_ATTRIBUTE = 'sprint_stamina_delay';
		default STAMINA_DELAY_JUMP_ATTRIBUTE = 'jump_stamina_delay';
		default STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE = 'usable_item_stamina_delay';
		default STAMINA_DELAY_ROLL_ATTRIBUTE = 'roll_stamina_delay';

	
	public const var TOXICITY_DAMAGE_THRESHOLD : float;									
		default TOXICITY_DAMAGE_THRESHOLD = 0.50001;	



	
	public const var DEBUG_CHEATS_ENABLED : bool;										
	public const var SKILL_GLOBAL_PASSIVE_TAG : name;									
	public const var TAG_OPEN_FIRE : name;												
	public const var TAG_MONSTER_SKILL : name;											
	public const var TAG_EXPLODING_GAS : name;											
	public const var ON_HIT_HP_REGEN_DELAY : float;										
	public const var TAG_NPC_IN_PARTY : name;											
	public const var TAG_PLAYERS_MOUNTED_VEHICLE : name;								
	public const var TAG_SOFT_LOCK : name;												
	public const var MAX_SPELLPOWER_ASSUMED : float;									
	public const var NPC_RESIST_PER_LEVEL : float;										
	public const var XP_PER_LEVEL : int;												
	public const var XP_MINIBOSS_BONUS : float;											
	public const var XP_BOSS_BONUS : float;												
	public const var ADRENALINE_DRAIN_AFTER_COMBAT_DELAY : float;						
	public const var KEYBOARD_KEY_FONT_COLOR : string;									
	public const var MONSTER_HUNT_ACTOR_TAG : name;										
	public const var GWINT_CARD_ACHIEVEMENT_TAG : name;									
	public const var TAG_AXIIABLE, TAG_AXIIABLE_LOWER_CASE : name;						
	public const var LEVEL_DIFF_DEADLY, LEVEL_DIFF_HIGH : int;							
	public const var LEVEL_DIFF_XP_MOD : float;											
	public const var MAX_XP_MOD : float;												
	public const var DEVIL_HORSE_AURA_MIN_DELAY, DEVIL_HORSE_AURA_MAX_DELAY : int;		
	public const var TOTAL_AMOUNT_OF_BOOKS	: int;										
	public const var MAX_PLAYER_LEVEL	: int;											
	
		default DEBUG_CHEATS_ENABLED = true;
		default SKILL_GLOBAL_PASSIVE_TAG = 'GlobalPassiveBonus';
		default TAG_MONSTER_SKILL = 'MonsterSkill';
		default TAG_OPEN_FIRE = 'CarriesOpenFire';
		default TAG_EXPLODING_GAS = 'explodingGas';
		default ON_HIT_HP_REGEN_DELAY = 2;
		default TAG_NPC_IN_PARTY = 'InPlayerParty';
		default TAG_PLAYERS_MOUNTED_VEHICLE = 'PLAYER_mounted_vehicle';
		default TAG_SOFT_LOCK = 'softLock';
		default MAX_SPELLPOWER_ASSUMED = 2;
		default NPC_RESIST_PER_LEVEL = 0.016;
		default XP_PER_LEVEL = 1;
		default XP_MINIBOSS_BONUS = 1.77;
		default XP_BOSS_BONUS = 2.5;
		default ADRENALINE_DRAIN_AFTER_COMBAT_DELAY = 3;
		default KEYBOARD_KEY_FONT_COLOR = "#CD7D03";
		default MONSTER_HUNT_ACTOR_TAG = 'MonsterHuntTarget';
		default GWINT_CARD_ACHIEVEMENT_TAG = 'GwintCollectorAchievement';
		default TAG_AXIIABLE = 'Axiiable';
		default TAG_AXIIABLE_LOWER_CASE = 'axiiable';
		default LEVEL_DIFF_HIGH = 10;	
		default LEVEL_DIFF_DEADLY = 20; 
		default LEVEL_DIFF_XP_MOD = 0.16f;
		default MAX_XP_MOD = 1.5f;
		default DEVIL_HORSE_AURA_MIN_DELAY = 2;
		default DEVIL_HORSE_AURA_MAX_DELAY = 6;
		default TOTAL_AMOUNT_OF_BOOKS = 130;
		default MAX_PLAYER_LEVEL = 100;
		
	
	public function Init()
	{
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('global_params');
				
		
		InitForbiddenAttributesList();
		
		SetWeaponDurabilityModifiers();
		
		SetArmorDurabilityModifiers();
			
		
		InitArmorAbilities();
		InitGlovesAbilities();
		InitPantsAbilities();
		InitBootsAbilities();
		InitWeaponAbilities();
		
		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS.Resize(5);
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[0] = 70;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[1] = 50;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[2] = 0;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[3] = 0;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[4] = 0;		
		
		newGamePlusLevel = FactsQuerySum("FinalNewGamePlusLevel");
	}
	
	private final function SetWeaponDurabilityModifiers()
	{
		var dur : SDurabilityThreshold;

		
		dur.difficulty = EDM_Easy;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.975;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.95;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Medium;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.95;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.9;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hard;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.925;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.85;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hardcore;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.9;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.8;
		durabilityThresholdsWeapon.PushBack(dur);
	}
	
	private final function SetArmorDurabilityModifiers()
	{
		var dur : SDurabilityThreshold;

		
		dur.difficulty = EDM_Easy;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.975;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.95;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Medium;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.95;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.9;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hard;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.925;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.85;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hardcore;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.9;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.8;
		durabilityThresholdsArmor.PushBack(dur);
	}
	
	public final function GetWeaponDurabilityLoseValue() : float
	{
		if(theGame.GetDifficultyMode() == EDM_Hardcore)
			return DURABILITY_WEAPON_LOSE_VALUE_HARDCORE;
		else
			return DURABILITY_WEAPON_LOSE_VALUE;		
	}
	
	private function InitArmorAbilities()
	{
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_Armor');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_SlashingResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_PiercingResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BludgeoningResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_RendingResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_ElementalResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_PoisonResistance');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_BleedingResistance');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_Vitality');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_AdrenalineGain');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
	}
	
	private function InitGlovesAbilities()
	{
		GLOVES_MASTERWORK_ABILITIES.PushBack('MA_Armor');
		GLOVES_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_PoisonResistance');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_BleedingResistance');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_AttackPowerMult');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_CriticalChance');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_CriticalDamage');
	}
	
	private function InitPantsAbilities()
	{
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_Armor');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_SlashingResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_PiercingResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_BludgeoningResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_RendingResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_ElementalResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		
		PANTS_MAGICAL_ABILITIES.PushBack('MA_PoisonResistance');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_BleedingResistance');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_Vitality');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_StaminaRegeneration');
	}
	
	private function InitBootsAbilities()
	{
		BOOTS_MASTERWORK_ABILITIES.PushBack('MA_Armor');
		BOOTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_PoisonResistance');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_BleedingResistance');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_StaminaRegeneration');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_AdrenalineGain');
	}
	
	private function InitWeaponAbilities()
	{
		
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_ArmorPenetration');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_CriticalChance');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_CriticalDamage');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_BleedingChance');
		
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_AdrenalineGain');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_PoisonChance');
		
	}
	
	
	private function InitForbiddenAttributesList()
	{
		var i,size : int;
	
		size = EnumGetMax('EBaseCharacterStats')+1;
		for(i=0; i<size; i+=1)
			forbiddenAttributes.PushBack(StatEnumToName(i));
			
		size = EnumGetMax('ECharacterDefenseStats')+1;
		for(i=0; i<size; i+=1)
		{
			forbiddenAttributes.PushBack(ResistStatEnumToName(i, true));
			forbiddenAttributes.PushBack(ResistStatEnumToName(i, false));
		}
			
		size = EnumGetMax('ECharacterPowerStats')+1;
		for(i=0; i<size; i+=1)
			forbiddenAttributes.PushBack(PowerStatEnumToName(i));
	}
	
	public function IsForbiddenAttribute(nam : name) : bool
	{
		if(!IsNameValid(nam))
			return true;
		
		return forbiddenAttributes.Contains(nam);
	}
	
	
	public function GetDurabilityMultiplier(durabilityRatio : float, isWeapon : bool) : float
	{
		if(isWeapon)
			return GetDurMult(durabilityRatio, durabilityThresholdsWeapon);
		else
			return GetDurMult(durabilityRatio, durabilityThresholdsArmor);
	}
	
	private function GetDurMult(durabilityRatio : float, durs : array<SDurabilityThreshold>) : float
	{
		var i : int;
		var currDiff : EDifficultyMode;
	
		currDiff = theGame.GetDifficultyMode();
		
		for(i=durs.Size()-1; i>=0; i-=1)
		{
			if(durs[i].difficulty == currDiff)			
				if(durabilityRatio <= durs[i].thresholdMax)
					return durs[i].multiplier;
		}
		
		return durs[0].multiplier;
	}
	
	
	public function GetRandomMasterworkArmorAbility() : name
	{
		return ARMOR_MASTERWORK_ABILITIES[RandRange(ARMOR_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalArmorAbility() : name
	{
		return ARMOR_MAGICAL_ABILITIES[RandRange(ARMOR_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkGlovesAbility() : name
	{
		return GLOVES_MASTERWORK_ABILITIES[RandRange(GLOVES_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalGlovesAbility() : name
	{
		return GLOVES_MAGICAL_ABILITIES[RandRange(GLOVES_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkPantsAbility() : name
	{
		return PANTS_MASTERWORK_ABILITIES[RandRange(PANTS_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalPantsAbility() : name
	{
		return PANTS_MAGICAL_ABILITIES[RandRange(PANTS_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkBootsAbility() : name
	{
		return BOOTS_MASTERWORK_ABILITIES[RandRange(BOOTS_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalBootsAbility() : name
	{
		return BOOTS_MAGICAL_ABILITIES[RandRange(BOOTS_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkWeaponAbility() : name
	{
		return WEAPON_MASTERWORK_ABILITIES[RandRange(WEAPON_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalWeaponAbility() : name
	{
		return WEAPON_MAGICAL_ABILITIES[RandRange(WEAPON_MAGICAL_ABILITIES.Size())];
	}
	
	
	public function GetStaminaActionAttributes(action : EStaminaActionType, getCostPerSec : bool, out costAttributeName : name, out delayAttributeName : name)
	{		
		switch(action)
		{
			case ESAT_LightAttack :
				costAttributeName = STAMINA_COST_LIGHT_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE;
				return;
			case ESAT_HeavyAttack :
				costAttributeName = STAMINA_COST_HEAVY_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE;
				return;
			case ESAT_SuperHeavyAttack :
				costAttributeName = STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE;
				return;
			case ESAT_LightSpecial :
				costAttributeName = STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE;
				return;
			case ESAT_HeavyAttack :
				costAttributeName = STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE;
				return;
			case ESAT_Parry :
				costAttributeName = STAMINA_COST_PARRY_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_PARRY_ATTRIBUTE;
				return;
			case ESAT_Counterattack :
				costAttributeName = STAMINA_COST_COUNTERATTACK_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE;
				return;
			case ESAT_Dodge :
				costAttributeName = STAMINA_COST_DODGE_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_DODGE_ATTRIBUTE;
				return;
			case ESAT_Roll :
				costAttributeName = STAMINA_COST_ROLL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_ROLL_ATTRIBUTE;
				return;
			case ESAT_Evade :
				costAttributeName = STAMINA_COST_EVADE_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_EVADE_ATTRIBUTE;
				return;
			case ESAT_Swimming :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE;
				}
				delayAttributeName = STAMINA_DELAY_SWIMMING_ATTRIBUTE;
				return;
			case ESAT_Sprint :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE;
				}
				else
				{
					costAttributeName = STAMINA_COST_SPRINT_ATTRIBUTE;
				}
				delayAttributeName = STAMINA_DELAY_SPRINT_ATTRIBUTE;
				return;
			case ESAT_Jump :
				costAttributeName = STAMINA_COST_JUMP_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_JUMP_ATTRIBUTE;
				return;
			case ESAT_UsableItem :
				costAttributeName = STAMINA_COST_USABLE_ITEM_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE;
				return;
			case ESAT_Ability :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_PER_SEC_DEFAULT;
				}
				else
				{
					costAttributeName = STAMINA_COST_DEFAULT;
				}
				delayAttributeName = STAMINA_DELAY_DEFAULT;
				return;
			default :
				LogAssert(false, "W3GameParams.GetStaminaActionAttributes : unknown stamina action type <<" + action + ">> !!");
				return;
		}		
	}	
	    
  	public function GetItemLevel(itemCategory : name, itemAttributes : array<SAbilityAttributeValue>, optional itemName : name, optional out baseItemLevel : int) : int
	{
		var stat : SAbilityAttributeValue;
		var stat_f : float;
		var stat1,stat2,stat3,stat4,stat5,stat6,stat7 : SAbilityAttributeValue;
		var stat_min, stat_add : float;
		var level : int;
	
		if ( itemCategory == 'armor' )
		{
				stat_min = 25;
				stat_add = 5;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'boots' )
		{
				stat_min = 5;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'gloves' )
		{
				stat_min = 1;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'pants' )
		{
				stat_min = 5;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'silversword' )
		{
				stat_min = 90;
				stat_add = 10;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat_f = (stat1.valueBase - 1) + (stat2.valueBase - 1) + (stat3.valueBase - 1) + (stat4.valueBase - 1) + (stat5.valueBase - 1) + (stat6.valueBase - 1);
			level = CeilF( 1 + ( 1 + stat_f - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'steelsword' )
		{
				stat_min = 25;
				stat_add = 8;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat7 = itemAttributes[6];
			stat_f = (stat1.valueBase - 1) + (stat2.valueBase - 1) + (stat3.valueBase - 1) + (stat4.valueBase - 1) + (stat5.valueBase - 1) + (stat6.valueBase - 1) + (stat7.valueBase - 1);
			level = CeilF( 1 + ( 1 + stat_f - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'bolt' )
		{
			if ( itemName == 'Tracking Bolt' ) { level = 2; } else
			if ( itemName == 'Bait Bolt' ) { level = 2; }  else
			if ( itemName == 'Blunt Bolt' ) { level = 2; }  else
			if ( itemName == 'Broadhead Bolt' ) { level = 10; }  else
			if ( itemName == 'Target Point Bolt' ) { level = 5; }  else
			if ( itemName == 'Split Bolt' ) { level = 15; }  else
			if ( itemName == 'Explosive Bolt' ) { level = 20; }  else
			if ( itemName == 'Blunt Bolt Legendary' ) { level = 5; }  else
			if ( itemName == 'Broadhead Bolt Legendary' ) { level = 20; }  else
			if ( itemName == 'Target Point Bolt Legendary' ) { level = 15; }  else
			if ( itemName == 'Blunt Bolt Legendary' ) { level = 12; }  else
			if ( itemName == 'Split Bolt Legendary' ) { level = 24; }  else
			if ( itemName == 'Explosive Bolt Legendary' ) { level = 26; } 

		}

		else if ( itemCategory == 'crossbow' )

		{
			stat = itemAttributes[0];
			level = 1;
			if ( stat.valueMultiplicative > 1.01 ) level = 2;
			if ( stat.valueMultiplicative > 1.1 ) level = 4;
			if ( stat.valueMultiplicative > 1.2 ) level = 8;
			if ( stat.valueMultiplicative > 1.3 ) level = 11;
			if ( stat.valueMultiplicative > 1.4 ) level = 15;
			if ( stat.valueMultiplicative > 1.5 ) level = 19;
			if ( stat.valueMultiplicative > 1.6 ) level = 22;
			if ( stat.valueMultiplicative > 1.7 ) level = 25;
			if ( stat.valueMultiplicative > 1.8 ) level = 27;
			if ( stat.valueMultiplicative > 1.9 ) level = 32;
		}  


		level = level - 1;
		if ( level < 1 ) level = 1;	
		baseItemLevel = level;
		if ( level > GetWitcherPlayer().GetMaxLevel() ) level = GetWitcherPlayer().GetMaxLevel();
		
		return level;
	}
	
	public final function SetNewGamePlusLevel(playerLevel : int)
	{
		if ( playerLevel > NEW_GAME_PLUS_MIN_LEVEL )
		{
			newGamePlusLevel = playerLevel;
		}
		else
		{
			newGamePlusLevel = NEW_GAME_PLUS_MIN_LEVEL;
		}
			
		FactsAdd("FinalNewGamePlusLevel", newGamePlusLevel);
	}
	
	public final function GetNewGamePlusLevel() : int
	{
		return newGamePlusLevel;
	}
	public final function NewGamePlusLevelDifference() : int
	{
		return ( theGame.params.GetNewGamePlusLevel() - theGame.params.NEW_GAME_PLUS_MIN_LEVEL );
	}
	public final function GetPlayerMaxLevel() : int
	{
		return MAX_PLAYER_LEVEL;
	}
}