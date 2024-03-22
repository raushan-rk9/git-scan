class Constants < ActiveRecord::Base
  # Get git revisions and tags
  # https://stackoverflow.com/a/24469132
  # Returns the rev of the current tree.
  GitRev = `git rev-parse --short HEAD`.chomp
  # Returns the latest tag.
  GitTag = `git describe --abbrev=0 --tags`.chomp
  # Returns the rev of the latest tag.
  GitTagRev = `git rev-parse --short --verify #{GitTag}^{commit}`.chomp

  AWC                             = 'Airworthiness Certification Services'
  UNDO                            = 'UNDO'
  REDO                            = 'REDO'
  UPLOAD_FILE                     = 'Upload File'
  REPLACE_FILE                    = 'Upload/Replace File'
  INITIAL_DRAFT_REVISION          = '0.1'
  INITIAL_VERSION                 = '0.0'

  # Archive Types
  PROJECT_ARCHIVE                 = 'PROJECT'
  DOCUMENT_ARCHIVE                = 'DOCUMENT'
  MODEL_ARCHIVE                   = 'MODEL'
  SYSTEM_REQUIREMENTS_ARCHIVE     = 'SYSTEM_REQUIREMENTS'
  HIGH_LEVEL_REQUIREMENTS_ARCHIVE = 'HIGH_LEVEL_REQUIREMENTS'
  LOW_LEVEL_REQUIREMENTS_ARCHIVE  = 'LOW_LEVEL_REQUIREMENTS'
  SOURCE_CODE_ARCHIVE             = 'SOURCE_CODE'
  TEST_CASE_ARCHIVE               = 'TEST_CASE'
  TEST_PROCEDURE_ARCHIVE          = 'TEST_PROCEDURE'
  REVIEW_ARCHIVE                  = 'REVIEW'
  MODULE_DESCRIPTION_ARCHIVE      = 'MODULE_DESCRIPTION'
  DOCUMENT_CHANGE                 = 'DOCUMENT_FILE'
  MODEL_CHANGE                    = 'MODEL_FILE'
  SOURCE_CODE_CHANGE              = 'SOURCE_CODE_FILE'
  PROBLEM_REPORT_CHANGE           = 'PROBLEM_REPORT_ATTACHMENT'
  TEST_PROCEDURE_CHANGE           = 'TEST_PROCEDURE_FILE'

  ArchiveType_hash                = {
    'Other'                           => nil,
    'Project Archive'                 => PROJECT_ARCHIVE,
    'Document Archive'                => DOCUMENT_ARCHIVE,
    'Model Archive'                   => MODEL_ARCHIVE,
    'System Requirements Archive'     => SYSTEM_REQUIREMENTS_ARCHIVE,
    'High level Requirements Archive' => HIGH_LEVEL_REQUIREMENTS_ARCHIVE,
    'Low level Requirements Archive'  => LOW_LEVEL_REQUIREMENTS_ARCHIVE,
    'Source Code Archive'             => SOURCE_CODE_ARCHIVE,
    'Test Case Archive'               => TEST_CASE_ARCHIVE,
    'Test Procedure Archive'          => TEST_PROCEDURE_ARCHIVE
  }

  ArtifactType_hash                = {
    'Documents'                       => 'documents',
    'Source Code'                     => 'source_codes',
    'Test Procedures'                 => 'test_procedures',
    'Other'                           => 'other'
  }

  # Folder Names
  SystemFolders_hash                  = {
    'Other'                           => nil,
    'Project Archive'                 => PROJECT_ARCHIVE,
    'Document Archive'                => DOCUMENT_ARCHIVE,
    'Model Archive'                   => MODEL_ARCHIVE,
    'System Requirements Archive'     => SYSTEM_REQUIREMENTS_ARCHIVE,
    'High level Requirements Archive' => HIGH_LEVEL_REQUIREMENTS_ARCHIVE,
    'Low level Requirements Archive'  => LOW_LEVEL_REQUIREMENTS_ARCHIVE,
    'Source Code Archive'             => SOURCE_CODE_ARCHIVE,
    'Test Case Archive'               => TEST_CASE_ARCHIVE,
    'Test Procedure Archive'          => TEST_PROCEDURE_ARCHIVE
  }

  # System Folder Names
  FOLDER_TYPE                         = 'Folder'
  ARCHIVED_DOCUMENTS                  = 'Archived Documents'
  INSTRUMENTED_CODE                   = 'Instrumented Code'

  # Review Attachment Types
  REVIEW_ATTACHMENT               = 'REVIEW'
  REFERENCE_ATTACHMENT            = 'REFERENCE'

  ReviewAttachmentType_hash       = {
    'Document Under Review'       => REVIEW_ATTACHMENT,
    'Reference Materials'         => REFERENCE_ATTACHMENT
  }

  # Attachment Types
  EXTERNAL_ATTACHMENT             = 'EXTERNAL'
  PACT_ATTACHMENT                 = 'PACT'
  UPLOAD_ATTACHMENT               = 'ATTACHMENT'
  INSTRUMENTS_ATTACHMENT          = 'INSTRUMENTED'

  AttachmentType_hash             = {
    'No Attachment'               => nil,
    'External URL'                => EXTERNAL_ATTACHMENT,
    'PACT Documents'              => PACT_ATTACHMENT,
    'File Upload'                 => UPLOAD_ATTACHMENT
  }

  # Review Type hash
  TRANSITION_REVIEW               = 'Transition Review'
  PEER_REVIEW                     = 'Peer Review'

  ReviewType_hash = {
    'Other'                       => nil,
    'Transition Review'           => TRANSITION_REVIEW,
    'Peer Review'                 => PEER_REVIEW
  }

  # Control Categories
  CONTROL_CATEGORY_1              ='Control Category 1'
  CONTROL_CATEGORY_2              ='Control Category 2'
  OTHER_CONTROL_CATEGORY          ='Other'

  ControlCategory                 = {
    'CC1/HC1'                     => CONTROL_CATEGORY_1,
    'CC2/HC2'                     => CONTROL_CATEGORY_2,
    'Other'                       => OTHER_CONTROL_CATEGORY
  }

  ItemType                        = {
    0                             => 'Other',
    1                             => 'DO-178',
    2                             => 'DO-254',
    3                             => 'DO-278',
    4                             => 'DO-160',
  }

  DisplayItemType                        = {
    0                             => 'Other',
    1                             => 'DO-178 Airborne Software',
    2                             => 'DO-254 Airborne Hardware',
    3                             => 'DO-278 Ground-based Software',
    4                             => 'DO-160 Environmentally Tested Airborne Hardware',
  }

  Export_RequirementTypes         = [
    'HTML',
    'PDF',
    'CSV',
    'XLS',
    'DOCX',
    # 'ReqIF'
  ]

  EMAIL                           = 'EMAIL'
  SECURITY_QUESTIONS              = 'SECURITY_QUESTIONS'
  TEXT_MESSAGE                    = 'TEXT_MESSAGE'
  AUTHENTICATED                   = 'AUTHENTICATED'
  PASSWORD_VALID                  = 'PASSWORD_VALID'
  LOGGED_OUT                      = 'LOGGED_OUT'
  LOGGED_IN                       = 'LOGGED_IN'
  EMAIL_CHALLENGE                 = 'EMAIL_CHALLENGE'
  TEXT_CHALLENGE                  = 'TEXT_CHALLENGE'
  SECURITY_CHALLENGE              = 'TEXT_CHALLENGE'

  Multifactor_Authentication_hash = {
    'None'                        => nil,
    'Email'                       => EMAIL,
    'Text Message'                => TEXT_MESSAGE,
    'Security Questions'          => SECURITY_QUESTIONS
  }

  Limited_Multifactor_Authentication_hash = {
    'Email'                       => EMAIL,
    'Text Message'                => TEXT_MESSAGE,
    'Security Questions'          => SECURITY_QUESTIONS
  }

  DocumentType                    = {
    'Code'                        => {
                                        description: 'Source Code',
                                        class:       'DO-178',
                                        dals:        [],
                                        category:    ''
                                     },
    'Conformity'                  => {
                                        description: 'Hardware Conformity',
                                        class:       'DO-178',
                                        dals:        [],
                                        category:    ''
                                     },
    'Document'                    => {
                                        description: 'Document'
                                     },
    'Design'                         => {
                                        description: 'HDL Code Review',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'Design.Code'                 => {
                                        description: 'Detailed Design - Code',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'Folder'                      => {
                                        description: 'Folder Containing other Documents'
                                     },
    'GENERAL'                     => {
                                        description: 'Software Planning',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'HAS'                         => {
                                        description: 'Hardware Accomplishment Summary',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'HCAR'                        => {
                                        description: 'Hardware Elemental Analysis Results',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HCI'                         => {
                                        description: 'Hardware Configuration Index',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HCIA'                        => {
                                        description: 'Hardware Change Impact Analysis',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HCMP'                        => {
                                        description: 'Hardware Configuration Management Plan',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HDD'                         => {
                                        description: 'Hardware Design Document',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HDP'                         => {
                                        description: 'Hardware Design Plan',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HDS'                         => {
                                        description: 'Hardware Design Standards',
                                        class:       'DO-254',
                                        dals:        ['A', 'B'],
                                        category:    ['CC2/HC2', 'CC2/HC2' ]
                                     },
    'HEAR'                        => {
                                        description: 'Hardware Elemental Analysis Results',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HECI'                        => {
                                        description: 'Hardware Environment Configuration Index',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'HPAP'                        => {
                                        description: 'Hardware Process Assurance Plan',
                                        class:       'DO-254',
                                        dals:        ['A', 'B'],
                                        category:    ['CC2/HC2', 'CC1/HC2' ]
                                     },
    'HRD'                         => {
                                        description: 'Hardware Requirements Document',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'HRS'                         => {
                                        description: 'Hardware Requirements Standards',
                                        class:       'DO-254',
                                        dals:        ['A', 'B'],
                                        category:    ['CC2/HC2', 'CC2/HC2' ]
                                     },
    'HTM'                         => {
                                        description: 'Hardware Trace Matrix',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HTP'                         => {
                                        description: 'Hardware Test Procedures',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HVS'                        => {
                                        description: 'Hardware Validation and Verification Standards ',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HVCP'                        => {
                                        description: 'Hardware Verification Cases and Procedures',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HVVP'                        => {
                                        description: 'Hardware Validation & Verification Plan',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HVP'                         => {
                                        description: 'Hardware Verification Plan',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'HVR'                         => {
                                        description: 'Hardware Verification Results',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'IP-COTS-PDH'                 => {
                                        description: 'IP, COTS and Previously Developed Hardware',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'MBDS'                        => {
                                        description: 'Model-Based Design Standards',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'Other'                       => {
                                        description: 'Other Type of Document'
                                     },
    'PDH'                         => {
                                        description: 'IP, COTS and Previously Developed Hardware',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'PDI'                         => {
                                        description: 'Parameter Data Items',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'PHAC'                        => {
                                        description: 'Plan for Hardware Aspects of Certification',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'Peer'                         => {
                                        description: 'Peer Review Checklist'
                                     },
    'Planning'                    => {
                                        description: 'Planning Checklist'
                                     },
    'PSAC'                        => {
                                        description: 'Plan for Software Aspects of Certification',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'RTM'                         => {
                                        description: 'Requirements Traceability Matrix',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SAS'                         => {
                                        description: 'Software Accomplishment Summary',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'SCAR'                        => {
                                        description: 'Structural Coverage Analysis Results',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },

    'SCI'                         => {
                                        description: 'Software Configuration Index',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'CIA'                          => {
                                        description: 'Software Change Impact Analysis',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'SCIA'                         => {
                                        description: 'Software Change Impact Analysis',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'SCMP'                        => {
                                        description: 'Software Configuration Management Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SCP'                         => {
                                        description: 'Software Conformity Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SCS'                         => {
                                        description: 'Software Code Standards',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C'],
                                        category:    ['CC2/HC2', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SDD'                         => {
                                        description: 'System Design Document',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC2/HC2' ]
                                     },
    'SDP'                         => {
                                        description: 'Software Development Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SDS'                         => {
                                        description: 'Software Design Standards',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2' ]
                                     },
    'SECI'                        => {
                                        description: 'Software Environment Configuration Index',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC2/HC2' ]
                                     },
    'SMS'                         => {
                                        description: 'Software Modeling Standards',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'Source Code'                 => {
                                        description: 'Source Code',
                                        class:       'DO-178',
                                        dals:        [],
                                        category:    ''
                                     },
    'SQAP'                        => {
                                        description: 'Software Quality Assurance Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SRD'                         => {
                                        description: 'System Requirements Document',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'SRS'                         => {
                                        description: 'Software Requirements Standards',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2' ]
                                     },
    'STM'                         => {
                                        description: 'Software Trace Matrix',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SVCP'                        => {
                                        description: 'Software Verification Cases and Procedures',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SVP'                         => {
                                        description: 'Software Verification Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SVR'                         => {
                                        description: 'Software Verification Results',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SWDD'                        => {
                                        description: 'Software Design Document',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'SWRD'                        => {
                                        description: 'Software Requirements Document',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC1/HC1', 'CC1/HC1' ]
                                     },
    'SWVCP'                       => {
                                        description: 'Software Verification Cases and Procedures',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TAS'                         => {
                                        description: 'Tool Accomplishment Summary',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TC'                          => {
                                        description: 'Tool Code',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TCI'                         => {
                                        description: 'Tool Configuration Index',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TCL'                         => {
                                        description: 'Tool Certification Liaison',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TCM'                          => {
                                        description: 'Tool Life Cycle and Environment Configuration Index',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TCMP'                        => {
                                        description: 'Tool Configuration Management Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TDP'                         => {
                                        description: 'Tool Development Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TECI'                        => {
                                        description: 'Tool Environmental Configuration Index',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TDD'                         => {
                                        description: 'Tool Design Description',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },


    'TDR'                         => {
                                        description: 'Tool (Development) Requirements',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'Template'                    => {
                                        description: 'Template',
                                        dals:        [],
                                        category:    ''
                                     },
    'TestProcedures'              => {
                                        description: 'Hardware Test Procedures',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TestResults'                 => {
                                        description: 'Hardware Test Results',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TIR'                         => {
                                        description: 'Tool Installation Report',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'Tool'                        => {
                                        description: 'Tool Qualification Plan',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TOR'                        => {
                                        description: 'Tool Operational Requirements',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TOVC'                        => {
                                        description: 'Tool Operational Verification Cases',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TOVR'                        => {
                                        description: 'Tool Op Verification Results',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TQ'                          => {
                                        description: 'Tool Qualification Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TQ.General'                  => {
                                        description: 'Tool Qualification Plan (General)',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TQAP'                        => {
                                        description: 'Tool Quality Assurance Plan',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TQP'                         => {
                                        description: 'Tool Qualification Plan',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TQR'                         => {
                                        description: 'Tool Qualification Results',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'T records'                   => {
                                        description: 'Tool QA & Records',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TS'                          => {
                                        description: 'Tool Standards',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TTD'                         => {
                                        description: 'Tool Trace Data',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TVC'                         => {
                                        description: 'Tool Verification Cases',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TVP'                         => {
                                        description: 'Tool Verification Plan',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'TVR'                         => {
                                        description: 'Tool Verification Results',
                                        class:       'DO-178',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     },
    'VVS'                         => {
                                        description: 'Validation and Verification Standards',
                                        class:       'DO-254',
                                        dals:        ['A', 'B', 'C', 'D'],
                                        category:    ['CC1/HC1', 'CC1/HC1', 'CC2/HC2', 'CC2/HC2' ]
                                     }
  }

  Document_Status                 = [
    'Open',
    'Closed'
  ]


  # Review main types.
  PR_Status                       = [
    'Open',
    'Implemented',
    'In-Work',
    'Investigate',
    'Verified',
    'Closed',
    'Deferred',
    'Rejected'
  ]

  PR_Status_Empty                 = [
    'Open'
  ]

  PR_Status_Open                  = [
    'Open',
    'Implemented',
    'In-Work',
    'Investigate',
    'Deferred',
    'Rejected'
  ]

  PR_Status_Assigned             = [
    'Open',
    'Implemented',
    'In-Work'
  ]

  PR_Status_Authorized           = [
    'Authorized',
    'In-Work',
    'Open'
  ]

  PR_Status_Implemented          = [
    'Implemented',
    'In-Work',
    'Verified',
    'Open'
  ]

  PR_Status_Verified             = [
    'Implemented',
    'Closed'
  ]

  PR_Status_Closed               = [
    'Closed'
  ]

  PR_Criticality                 = [
    'Type 0 - Failure (Safety Impact)',
    'Type 1A - Failure (No Safety Impact)',
    'Type 1B - Failure (Insignificant Consequences)',
    'Type 2 - Other Fault (No Failure)',
    'Type 3A - Process (Significant Deviation)',
    'Type 3B - Process (Insignificant Deviation)',
    'Type 4 - Enhancements or Documentation'
  ]

  PR_DisiciplineAssigned         = [
    'Engineering',
    'Manufacturing',
    'Quality',
    'Other',
    'Not Assigned'
  ]

  PR_Source                      = [
    'Internal',
    'Customer',
    'Cert Authority',
    'Other'
  ]

  # Test types.
  Test_Types                     = [
    'Review/Inspection',
    'Analysis/Simulation',
    'Test'
  ]

  # Review main types.
  ReviewType                     = [
    'Other',
    'Quality Assurance Review',
    'Peer Review',
    'Transition Review'
  ]

  DO_178_Review_Type             = [
    'Peer Review - Planning',
    'Peer Review - Requirements',
    'Peer Review - Conceptual Design',
    'Peer Review - Code',
    'Peer Review - Integration',
    'Peer Review - Test Procedures',
    'Peer Review - Test Results',
    'Peer Review - Accomplishment Summary',
    'Transition Review - Planning',
    'Transition Review - Requirements',
    'Transition Review - Preliminary Design',
    'Transition Review - Critical Design',
    'Transition Review - Code',
    'Transition Review - Integration',
    'Transition Review - Verification',
    'Transition Review - Conformity',
    'Compliance Stages of Involvement - Planning',
    'Compliance Stages of Involvement - Development',
    'Compliance Stages of Involvement - Verification',
    'Compliance Stages of Involvement - Final',
  ]

  DO_256_Review_Type             = [
    'Other',
    'Quality Assurance Review',
    'Peer Review',
    'Transition Review'
  ]

  DO_278_Review_Type             = [
    'Other',
    'Quality Assurance Review',
    'Peer Review',
    'Transition Review'
  ]

  DO_160_Review_Type             = [
    'Other',
    'Quality Assurance Review',
    'Peer Review',
    'Transition Review'
  ]

  # Review status types.
  ReviewStatus                   = [
    'Pass',
    'Fail'
  ]

  # Review subtype names.
  ReviewSubtype_QA_DO178         = {
    0                            => 'Other',
    1                            => 'Planning Review',
    2                            => 'Development Plan Review',
    3                            => 'Verification Plan Review',
    4                            => 'Configuration Management Plan Review',
    5                            => 'Quality Assurance Plan Review',
    6                            => 'Requirements Standard Review',
    7                            => 'Design Standards Review',
    8                            => 'Code Standards Reivew',
    9                            => 'Requirements Document Review',
    10                           => 'Design Description Review',
    11                           => 'Test Case Review',
    12                           => 'Test Environment Configuration Review',
    13                           => 'Configuration Index Review',
    14                           => 'Accomplishment Summary Review'
  }
  ReviewSubtype_Peer_DO178 = {
    0                            => 'Other',
    1                            => 'System/Safety Review',
    2                            => 'Planning Review',
    3                            => 'Requirements Review',
    4                            => 'Design Review',
    5                            => 'Code Review',
    6                            => 'Integration Review',
    7                            => 'Test Procedures Review',
    8                            => 'Test Results Review',
  }
  ReviewSubtype_Transition_DO178 = {
    0                            => 'Other',
    1                            => 'Software Planning Review',
    2                            => 'Software Requirements Review',
    3                            => 'Software Preliminary Design Review',
    4                            => 'Software Critical Design Review',
    5                            => 'Software Code Review',
    6                            => 'Software Integration Review',
    7                            => 'Software Verification Review',
    8                            => 'Software Conformity Review',
  }
  Review_Supplements             = [
    'Model Based',
    'Formal Method',
    'Object Oriented',
    'DO-330'
  ]
  Review_Dals                    = [
    'A',
    'B',
    'C',
    'D',
    'E',
    '1',
    '2',
    '3',
    '4'
  ]

  Template_Dals                  = [
    'A',
    'B',
    'C',
    'D',
    'E',
    '1',
    '2',
    '3',
    '4',
    'N/A'
  ]

  TemplateItemType               = [
    'Other',
    'DO-178',
    'DO-254',
    'DO-278',
    'DO-160'
  ]

end
