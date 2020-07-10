#include "TradingCommon.as"
#include "Descriptions.as"

#define SERVER_ONLY

int coinsOnDamageAdd = 2;
int coinsOnKillAdd = 10;
int coinsOnDeathLose = 10;
int min_coins = 50;
int max_coins = 500; //changed from 200

//
string cost_config_file = "tdm_vars.cfg";
bool kill_traders_and_shops = false;

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (blob.getName() == "tradingpost")
	{
		if (kill_traders_and_shops)
		{
			blob.server_Die();
			KillTradingPosts();
		}
		else
		{
			MakeTradeMenu(blob);
		}
	}
}

TradeItem@ addItemForCoin(CBlob@ this, const string &in name, int cost, const bool instantShipping, const string &in iconName, const string &in configFilename, const string &in description)
{
	if(cost <= 0) {
		return null;
	}

	TradeItem@ item = addTradeItem(this, name, 0, instantShipping, iconName, configFilename, description);
	if (item !is null)
	{
		AddRequirement(item.reqs, "coin", "", "Coins", cost);
		item.buyIntoInventory = true;
	}
	return item;
}

void MakeTradeMenu(CBlob@ trader)
{
	//load config

	if (getRules().exists("tdm_costs_config"))
		cost_config_file = getRules().get_string("tdm_costs_config");

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	s32 cost_bombs = cfg.read_s32("cost_bombs", -20);
	s32 cost_waterbombs = cfg.read_s32("cost_waterbombs", -40);
	s32 cost_keg = cfg.read_s32("cost_keg", -80);
	s32 cost_mine = cfg.read_s32("cost_mine", -50);

	s32 cost_arrows = cfg.read_s32("cost_arrows", -10);
	s32 cost_waterarrows = cfg.read_s32("cost_waterarrows", -40);
	s32 cost_firearrows = cfg.read_s32("cost_firearrows", -30);
	s32 cost_bombarrows = cfg.read_s32("cost_bombarrows", -50);

	s32 cost_boulder = cfg.read_s32("cost_boulder", 50);
	s32 cost_burger = -40;
	s32 cost_sponge = cfg.read_s32("cost_sponge", -20);

	s32 cost_mountedbow = cfg.read_s32("cost_mountedbow", -1);
	s32 cost_drill = cfg.read_s32("cost_drill", -1);
	s32 cost_catapult = cfg.read_s32("cost_catapult", -1);
	s32 cost_ballista = cfg.read_s32("cost_ballista", -1);

	s32 cost_dodgeball = 10;
	s32 cost_bouncyball = 20;
	s32 cost_bouncykeg = 50;
	s32 cost_cookie = 40;
	s32 cost_bouncymine = 50;

	s32 menu_width = cfg.read_s32("trade_menu_width", 3);
	s32 menu_height = cfg.read_s32("trade_menu_height", 3);

	// build menu
	CreateTradeMenu(trader, Vec2f(menu_width, menu_height), "Buy weapons");

	//
	addTradeSeparatorItem(trader, "$MENU_GENERIC$", Vec2f(3, 1));

	if(cost_dodgeball > 0)
		addItemForCoin( trader, "Dodgeball", cost_dodgeball, true, "$dodgeball$", "dodgeball", "A dodgeball for you to play around with." );

	if(cost_bouncyball > 0)
		addItemForCoin( trader, "Bouncy Ball", cost_bouncyball, true, "$bouncyball$", "bouncyball", "Like a dodgeball, but bouncier." );

	if(cost_burger > 0)
		addItemForCoin( trader, "Burger", cost_burger, true, "$food$", "food", "Food for healing. Don't think about this too much." );

	if(cost_cookie > 0)
		addItemForCoin( trader, "Cookie", cost_cookie, true, "$cookie$", "cookie", "Cookie for healing. Moves like a dodgeball.");

	//if(cost_mine > 0)
	//	addItemForCoin( trader, "Mine", cost_mine, true, "$mine$", "mine", "An explosive mine, triggered by contact with an enemy." ); //it still shows up in the buy menu
	
	if(cost_boulder > 0)
		addItemForCoin( trader, "Boulder", cost_boulder, true, "$boulder$", "boulder", "A stone boulder useful for crushing enemies." );	
		
	if(cost_bouncykeg > 0)
		addItemForCoin( trader, "Bouncy Keg", cost_bouncykeg, true, "$bouncykeg$", "bouncykeg", "Like a keg, but bouncier." );	 

	if(cost_bombs > 0)
		addItemForCoin( trader, "Bomb", cost_bombs, true, "$mat_bombs$", "mat_bombs", "Bombs for Knight only." );

	if(cost_waterbombs > 0)
		addItemForCoin( trader, "Water Bomb", cost_waterbombs, true, "$mat_waterbombs$", "mat_waterbombs", "Water bomb for Knight. Can extinguish fires and stun enemies." );

	//if(cost_keg > 0)
	//	addItemForCoin( trader, "Keg", cost_keg, true, "$keg$", "keg", "Highly explosive powder keg for Knight only." ); // it still shows up in the buy menu

	if(cost_arrows > 0)
		addItemForCoin( trader, "Arrows", cost_arrows, true, "$mat_arrows$", "mat_arrows", "Arrows for Archer and mounted bow." );	 

	if(cost_waterarrows > 0)
		addItemForCoin( trader, "Water Arrows", cost_waterarrows, true, "$mat_waterarrows$", "mat_waterarrows", "Water arrows for Archer. Can extinguish fires and stun enemies." );	 

	if(cost_firearrows > 0)
		addItemForCoin( trader, "Fire Arrows", cost_firearrows, true, "$mat_firearrows$", "mat_firearrows", "Fire arrows used to set wooden structures on fire." );	 

	if(cost_bombarrows > 0)
		addItemForCoin( trader, "Bomb Arrow", cost_bombarrows, true, "$mat_bombarrows$", "mat_bombarrows", "Bomb arrows for Archer." );

	if(cost_mountedbow > 0)
		addItemForCoin( trader, "Mounted Bow", cost_mountedbow, true, "$mounted_bow$", "mounted_bow", "A stationary arrow-firing death machine." );	 

	if(cost_drill > 0)
		addItemForCoin( trader, "Drill", cost_drill, true, "$drill$", "drill", "A mining drill. Increases speed of digging and gathering resources, but gains only half the possible resources." );	 
	
	if(cost_catapult > 0)
		addItemForCoin( trader, "Catapult", cost_catapult, true, "$catapult$", "catapult", "A stone throwing, ridable siege engine, requiring a crew of two." );	 

	if(cost_ballista > 0)
		addItemForCoin( trader, "Ballista", cost_ballista, true, "$ballista$", "ballista", "A bolt-firing pinpoint accurate siege engine, requiring a crew of two. Allows respawn and class change." );	 
	
	if(cost_bouncymine > 0)
		addItemForCoin( trader, "Bouncy Mine", cost_bouncymine, true, "$bouncymine$", "bouncymine", "A bouncy mine, triggered on contact with enemy." );


}

// load coins amount

void Reset(CRules@ this)
{
	//load the coins vars now, good a time as any
	if (this.exists("tdm_costs_config"))
		cost_config_file = this.get_string("tdm_costs_config");

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	coinsOnDamageAdd = cfg.read_s32("coinsOnDamageAdd", coinsOnDamageAdd);
	coinsOnKillAdd = cfg.read_s32("coinsOnKillAdd", coinsOnKillAdd);
	coinsOnDeathLose = cfg.read_s32("coinsOnDeathLose", coinsOnDeathLose);
	min_coins = cfg.read_s32("minCoinsOnRestart", min_coins);
	max_coins = cfg.read_s32("maxCoinsOnRestart", max_coins);

	kill_traders_and_shops = !(cfg.read_bool("spawn_traders_ever", true));

	if (kill_traders_and_shops)
	{
		KillTradingPosts();
	}

	//clamp coin vars each round
	for (int i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		s32 coins = player.getCoins();
		if (min_coins >= 0) coins = Maths::Max(coins, min_coins);
		if (max_coins >= 0) coins = Maths::Min(coins, max_coins);
		player.server_setCoins(coins);
	}

}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}


void KillTradingPosts()
{
	CBlob@[] tradingposts;
	bool found = false;
	if (getBlobsByName("tradingpost", @tradingposts))
	{
		for (uint i = 0; i < tradingposts.length; i++)
		{
			CBlob @b = tradingposts[i];
			b.server_Die();
		}
	}
}

// give coins for killing

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (victim !is null)
	{
		if (killer !is null)
		{
			if (killer !is victim && killer.getTeamNum() != victim.getTeamNum())
			{
				killer.server_setCoins(killer.getCoins() + coinsOnKillAdd);
			}
		}

		victim.server_setCoins(victim.getCoins() - coinsOnDeathLose);
	}
}

// give coins for damage

f32 onPlayerTakeDamage(CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale)
{
	if (attacker !is null && attacker !is victim)
	{
		attacker.server_setCoins(attacker.getCoins() + DamageScale * coinsOnDamageAdd / this.attackdamage_modifier);
	}

	return DamageScale;
}
