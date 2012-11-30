
enum ballType {
    ballTypeNormal, ballTypeSmall, ballTypeFire, ballTypeFaster_forTTL, ballTypeSucked_forTTL,ballTypeNULL//用來表示現在不用換type
};
//被複製出來的球進洞一次就會消失了
enum fasterType {
    fasterTypeItem,
    fasterTypeShock//因為大震動也會把速度加快，只是時間比較短
};

enum gravityLineType {
    gravityLineTypeHorizontal,
    gravityLineTypeVertical
};

enum ItemType {
    randomDefault=-1,//用來初始化random用，沒有其他意義
    adNumber=7,
    environmentalNumber=6,
    adRandom=967,//攻擊防禦
    environmentalRandom,//環境
    
    itemBallSucked = 970,
    itemBoardBigger,
    itemBoardSmaller,
    itemFreezeBoard,
    itemTableDissapear,
    itemTableSmaller,
    itemTableWider,
    
    itemThunder=977,
    itemBallFaster,
    itemFireBall,
    itemBallSmaller,
    itemSplit2,
    itemSplit10,
    
};

enum scoreLocation {
    scoreUpper = 1000,
    scoreUpper10,
    scoreLower,
    scoreLower10
};

enum RulerType {
    RulerTypeUpper = 995,
    RulerTypeLower
};

enum SpecialTablePartsType {
    SpecialTablePartsTypeNormal,
    SpecialTablePartsTypeSmaller,
    SpecialTablePartsTypeWider,
    SpecialTablePartsTypeDissapear
};

enum TablePartsType {
    TablePartsTypeUpper,
    TablePartsTypeLower,
    TablePartsTypeLeft,
    TablePartsTypeRight
};

typedef enum
{
	user_board_type_player=950,
	user_board_type_enemy,
    user_board_type_nobody
} user_board_type;

typedef enum
{
	specialBoardTypeNormal=900,
	specialBoardTypeBigger,
    specialBoardTypeSmaller,
    specialBoardTypeFreezed
} specialBoardType;

typedef enum
{
	ballEffectTypeBall2Ball,
	ballEffectTypeBall2Board,
    ballEffectTypeBall2table,
    ballEffectTypeBoard2Board,
    ballEffectTypeSmallBallSelf,
    ballEffectTypeFireBallSelf,
    ballEffectTypeMagicRuler,
    ballEffectTypeSuck,
    ballEffectTypeItemGet,
    ballEffectTypeTableChange,
    ballEffectTypeuser_boardChange,
} ballEffectType;

typedef enum
{
    TTLtimeSmaller=5,
    TTLtimeFire=5,
    TTLtimeSucked=10,
    TTLtimefasterLevel1=5,
    TTLtimefasterLevel2=2,
    TTLtimeuser_boardChange=2
}TTLtime;
