import EctoEnum

defenum(JourneyTypeEnum,
  # primary journey maps may only be done once per person
  primary: 0,
  # template journey mays may be redone and applied to different uses
  template: 1
)

defenum(JourneyStatusEnum,
  unknown: 0,
  preparing: 1,
  open: 2,
  closed: 3
)

# defenum(JourneySchemaClueVisibilityEnum,
#   unknown: 0,
#   visible: 1,
#   hidden: 2
# )
