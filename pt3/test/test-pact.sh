#!/usr/bin/env bash

RUN_MODELS="Yes"
RUN_CONTROLLERS="Yes"
RUN_SYSTEM="Yes"
PAUSE="Yes"
AUTO_RETRY="No"
FLUSH_TMP="No"

for argument in "$@"
do
  case $argument in
    --flush*)
      FLUSH_TMP="Yes"
    ;;
    --no_pause*)
      PAUSE="No"
      AUTO_RETRY="Yes"
    ;;
    --no_model*)
      RUN_MODELS="No"
    ;;
    --no_controller*)
      RUN_CONTROLLERS="No"
    ;;
    --no_system*)
      RUN_SYSTEM="No"
    ;;
    --help*)
      echo 'usage: test-pact [--no_pause][--no_model][--no_controller][--no_system][--help]'
    ;;
  esac
done

execute_test() {
  REPEAT="Yes"
  FIRST="Yes"

  while [ $REPEAT = "Yes" ]
  do
    if [ "$FLUSH_TMP" = "Yes" ]
    then
      rm -f /tmp/*/*/*
    fi

    date
    rails test test/${1}/${2}_test.rb

    if [ "$?" = "1" ]
    then
      if [ "$AUTO_RETRY" = "Yes" ]
      then
        if [ "$FIRST" = "Yes" ]
        then
          FIRST="No"
          REPLY="r"
        else
          REPEAT="No"
          REPLY=""
        fi
      fi
    else
      REPEAT="No"
      REPLY=""
    fi

    if [ "$PAUSE" = "Yes" ]
    then
      printf "\e[35m\e[1m>>> Press enter to continue, r to repeat, q to quit.\e[0m\n"
      read
    fi

    case $REPLY in
      q*)
        exit 0
      ;;

      r*)
        REPEAT="Yes"
      ;;

      *)
        REPEAT="No"
      ;;

    esac
  done
}

execute_tests() {
  TYPE=$1
  shift

  printf "\e[34m\e[1m*** Executing $TYPE Tests.\e[0m\n"

  for test in "$@"
  do
    printf "\e[32m\e[1m*** Running test/${TYPE}/${test}_test.rb.\e[0m\n"

    if [ "$PAUSE" = "Yes" ]
    then
      printf "\e[35m\e[1m>>> Press enter to continue, q to quit or s skip.\e[0m\n"
      read
    fi

    case $REPLY in
      q*)
        exit 0
      ;;

      s*)
        SKIP="Yes"
      ;;

      *)
        SKIP="No"
      ;;
    esac

    if [ "$SKIP" = "No" ]
    then
      execute_test "$TYPE" "$test"
    fi
  done
}

# Model Tests
#  execute_tests models *

if [ "$RUN_MODELS" = "Yes" ]
then
  execute_tests models \
    user \
    licensee \
    project \
    change_session \
    data_change \
    model_file \
    system_requirement \
    problem_report_attachment \
    problem_report_history \
    problem_report \
    review_attachment \
    item \
    document_type \
    document_attachment \
    document_comment \
    document \
    high_level_requirement \
    low_level_requirement \
    code_checkmark \
    source_code \
    test_case \
    test_procedure \
    action_item \
    checklist_item \
    requirements_tracing \
    review_attachment \
    review \
    archive \
    template_checklist_item \
    template_checklist \
    template_document \
    template
fi

# Controller Tests
#  execute_tests controllers *

if [ "$RUN_CONTROLLERS" = "Yes" ]
then
  execute_tests controllers \
    users_controller \
    licensees_controller \
    projects_controller \
    model_files_controller \
    system_requirements_controller \
    problem_report_attachments_controller \
    problem_report_histories_controller \
    problem_reports_controller \
    items_controller \
    document_types_controller \
    document_attachments_controller \
    document_comments_controller \
    documents_controller \
    high_level_requirements_controller \
    low_level_requirements_controller \
    module_descriptions_controller \
    source_codes_controller \
    test_cases_controller \
    test_procedures_controller \
    requirements_tracing_controller \
    action_items_controller \
    checklist_items_controller \
    review_attachments_controller \
    reviews_controller \
    archives_controller \
    template_checklist_items_controller \
    template_checklists_controller \
    template_documents_controller \
    templates_controller
fi

# System Tests
#  execute_test system *

if [ "$RUN_SYSTEM" = "Yes" ]
then
  execute_tests system \
    users \
    licensees \
    projects \
    model_files \
    system_requirements \
    problem_report_attachments \
    problem_report_histories \
    problem_reports \
    items \
    document_types \
    document_attachments \
    document_comments \
    documents \
    high_level_requirements \
    low_level_requirements \
    module_descriptions \
    source_codes \
    test_cases \
    test_procedures \
    requirements_tracing \
    action_items \
    checklist_items \
    review_attachments \
    reviews \
    archives \
    template_checklist_items \
    template_checklists \
    template_documents \
    templates
fi
