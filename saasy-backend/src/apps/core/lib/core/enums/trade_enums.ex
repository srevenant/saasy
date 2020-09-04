import EctoEnum

defenum(TradeOptionTypeEnum, buy: 0, sell: 1, auction: 2, trade: 3)

defenum(TradeThreadInteractionTypeEnum,
  open: 0,
  offered: 1,
  accepted: 2,
  declined: 3,
  closed: 4
)

defenum(TradeStatusEnum, open: 0, pending: 1, sold: 2, closed: 3)

defenum(TradeItemTypeEnum, sell: 0, buy: 1)
defenum(TradeMemberRoleEnum, sell: 0, buy: 1, courier: 2)

# note: invite/accept are joining the deal, decline/agree are negotiation, removed is to go away
defenum(TradeMemberStatusEnum,
  invite: 0,
  participant: 1,
  decline: 2,
  agree: 3,
  remove: 4,
  close: 5
)
