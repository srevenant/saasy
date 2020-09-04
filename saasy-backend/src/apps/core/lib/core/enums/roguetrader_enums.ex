import EctoEnum

defenum(GamePlatformTypeEnum,
  ps4: 0,
  xbox: 1,
  pc: 2
)

# avoiding magic where possible - like a static config, but w/the enum
defmodule GamePlatformTypeEnums do
  def values do
    [:ps4, :xbox, :pc]
  end
end

defenum(GameTaxonomyX1Enum, effect: 1, thing: 2)
defenum(GameTaxonomyX2Enum, weapon: 1, armor: 2)
defenum(GameTaxonomyX3Enum, ranged: 1, melee: 2)

defenum(PostGroupEnum, test: 0, news: 1, bethesda_speaks: 2)
defenum(PostContentTypeEnum, title: 1, blurb: 2, author: 3, body: 5)
