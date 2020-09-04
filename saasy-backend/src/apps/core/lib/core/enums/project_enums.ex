import EctoEnum

################################################################################
defenum(ProjectStatusEnum,
  private: 0,
  public: 1,
  closed: 2
)

defenum(ProjectStageEnum, concept: 0, ember: 1, ignite: 2, scale: 3)

defenum(ProjectMemberTypeEnum,
  admin: 0,
  contributor: 1,
  supporter: 2,
  investor: 3,
  sponsor: 4,
  reviewer: 5
)

defenum(ProjectMemberRoleEnum,
  # makers
  techdev: 0,
  bizdev: 1,
  design: 2,
  # facilitators
  product: 3,
  project: 4,
  techops: 5,
  bizops: 6,
  # sustainors
  customer: 7,
  sales: 8,
  marketing: 9,
  finance: 10
)

defenum(ProjectDataTypeEnum,
  profile: 0,
  needs: 1
)

################################################################################
defenum(PitchTypeEnum,
  lightning: 0,
  deck: 1
)

defenum(PitchStatusEnum, preparing: 0, feedback: 1, archive: 2, cancel: 3)
