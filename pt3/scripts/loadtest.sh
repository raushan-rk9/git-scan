#!/bin/bash

# Get folder of this script
SCRIPTSOURCE="${BASH_SOURCE[0]}"
FLWSOURCE="$(readlink -f "$SCRIPTSOURCE")"
SCRIPTDIR="$(dirname "$FLWSOURCE")"

# Change to assumed project root folder.
cd "$SCRIPTDIR"/../

# Load users fixture.
echo "Loading all fixtures into database."
rails db:fixtures:load FIXTURES=users,projects,items,problem_reports,problem_report_histories,problem_report_attachments,documents,document_attachments,document_comments,reviews,review_attachments,checklist_items,action_items,high_level_requirements,low_level_requirements,system_requirements,test_cases,module_descriptions
fecho "Done."
