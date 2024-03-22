#!/bin/sh

if [ "$1" = "--only_users" ]
then
    shift                                                                      ;
    only_users=true
else
    only_users=""
fi

if [ "$1x" = "x" ]
then
    environment=production
else
    environment=$1                                                 
fi

if [ "${DROP_DATABASE_ON_RELOAD}x" != "x" ]
then
    RAILS_ENV=$environment bundle exec rails db:environment:set                ;
    RAILS_ENV=$environment bundle exec rake db:drop                            ;
    RAILS_ENV=$environment bundle exec rake db:create                          ;
    RAILS_ENV=$environment bundle exec rake db:migrate                         ;
    RAILS_ENV=$environment bundle exec rake db:seed
else
    RAILS_ENV=$environment bundle exec rake db:rollback STEP=200               ;
    RAILS_ENV=$environment bundle exec rake db:migrate                         ;
    RAILS_ENV=$environment bundle exec rake db:seed
fi

if [ "$only_users" = "" ]
then
    RAILS_ENV=$environment bundle exec rails db:fixtures:load FIXTURES=users
else
    if [ $environment = "production" ]
    then
        RAILS_ENV=$environment bundle exec rails db:fixtures:load FIXTURES=users_prod,projects,items,problem_reports,problem_report_histories,problem_report_attachments,documents,document_attachments,document_comments,reviews,review_attachments,checklist_items,action_items,high_level_requirements,low_level_requirements,system_requirements,test_cases,module_descriptions,function_items
    else
        RAILS_ENV=$environment bundle exec rails db:fixtures:load FIXTURES=users,projects,items,problem_reports,problem_report_histories,problem_report_attachments,documents,document_attachments,document_comments,reviews,review_attachments,checklist_items,action_items,high_level_requirements,low_level_requirements,system_requirements,test_cases,module_descriptions,function_items
    fi
fi
