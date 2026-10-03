---
title: "Data Migration: Incorrectly Created IC Contract Records"
jira_key: "CLM-424"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "In Progress"
jira_priority: "High"
jira_url: "https://jira.cs.sys/browse/CLM-424"
jira_assignee: "Liz Glass"
jira_reporter: "Liz Glass"
jira_created: "2026-06-17T21:38:34.014+0000"
jira_updated: "2026-09-28T16:08:48.461+0000"
pulled_at: "2026-09-29T12:12:08.334853+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-424: Data Migration: Incorrectly Created IC Contract Records

**Type**: Task
**Status**: In Progress
**Priority**: High
**Assignee**: Liz Glass
**Reporter**: Liz Glass
**Created**: 2026-06-17T21:38:34.014+0000
**Updated**: 2026-09-28T16:08:48.461+0000
**URL**: https://jira.cs.sys/browse/CLM-424

**Labels**: datamigration, legal
**Components**: Ironclad, Salesforce

## Description

*As a* Legal team member
*I want* to identify and remove contract records that were incorrectly created during data migration when the CLM stage indicated 'with sales' on the request form
*So that* I can ensure only records with final signed documents exist in the system and maintain data integrity for compliance requests
h3. Acceptance Criteria
 * [ ] System identifies contract records created during data migration that have redlined (non-final) documents attached
 * [ ] Cross-reference contract records against historical request form data to determine CLM stage at time of migration
 * [ ] Flag contract records where request form indicated 'with sales' status during migration
 * [ ] Validation process to confirm these records should not have been created
 * [ ] Bulk deletion capability for incorrectly created contract records
 * [ ] Audit trail documenting which records were removed and why
 * [ ] Exception handling for edge cases requiring manual review

h3. Investigation Requirements
 * [ ] Analysis of data migration logs and timestamps
 * [ ] Historical request form status tracking at time of migration
 * [ ] Document type validation (redlined vs. final signed documents)
 * [ ] Cross-system data correlation between migration records and request forms

h3. Technical Requirements
 * [ ] Query capability to identify migration-created records with 'with sales' status
 * [ ] Data validation rules to distinguish between redlined and final documents
 * [ ] Backup and recovery process before bulk deletions

h3. Alternative Solutions Evaluation
 * [ ] Investigate request form status history retrieval methods
 * [ ] Evaluate document metadata for migration timing correlation
 * [ ] Consider CLM workflow stage indicators as alternative identification method
 * [ ] Document recommended approach based on data availability and accuracy

h3. Risk Mitigation
 * [ ] Staged deletion process with review checkpoints
 * [ ] Rollback capability if incorrect records are identified for deletion
 * [ ] Stakeholder approval before executing bulk deletions
 * [ ] Communication plan for affected users and downstream systems

 

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 4.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@1083f9e[activatedDate=2026-07-01T19:13:06.208Z,autoStartStop=false,completeDate=2026-07-23T15:45:55.222Z,endDate=2026-07-15T20:53:00.000Z,goal=,id=18851,incompleteIssuesDestinationId=<null>,name=CLM Sprint 17,rapidViewId=9801,sequence=18851,startDate=2026-07-01T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6c0eb9c0[activatedDate=2026-07-23T15:46:21.488Z,autoStartStop=false,completeDate=2026-08-03T20:59:14.090Z,endDate=2026-07-29T20:53:00.000Z,goal=,id=18852,incompleteIssuesDestinationId=<null>,name=CLM Sprint 18,rapidViewId=9801,sequence=18852,startDate=2026-07-15T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4144d916[activatedDate=2026-08-03T21:00:06.384Z,autoStartStop=false,completeDate=2026-08-20T12:35:48.048Z,endDate=2026-08-19T20:53:00.000Z,goal=<null>,id=18853,incompleteIssuesDestinationId=<null>,name=CLM Sprint 19,rapidViewId=9801,sequence=18853,startDate=2026-07-29T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@44126a3e[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4a659ed[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]'] |
| `customfield_11300` | Rank | "2|hypevc:07c3nb" |
| `customfield_11700` | Time in Status | "3_*:*_1_*:*_0_*|*_10031_*:*_1_*:*_1722311922" |
| `customfield_11701` | Date of First Response | "2026-07-23T12:18:42.701+0000" |
| `customfield_13400` | Development | "{}" |
| `customfield_14221` | Template | "{}" |
| `customfield_14410` | Notification Count | 0 |
| `customfield_15236` | Deployed to CIDs | "None" |
| `customfield_15238` | PIR | ['PIRS_GO_HERE'] |
| `customfield_15606` | MI | "null" |
| `customfield_15611` | Exploit Type | "null" |
| `customfield_16009` | Report ID | "null" |
| `customfield_16026` | Shown In UI | No |
| `customfield_17605` | Coordinating Architect (CAT) Effort | TBD |
| `customfield_17608` | Product Manager (PM) | None Assigned |
| `customfield_17629` | Crypto Justification | Expiration |
| `customfield_17641` | Last Comment | "[~eglass] here's the updated report - [https://docs.google.com/spreadsheets/d/1-xvi29p2o8LeXPxXKwT2xVg8oUCDk_Gt7uWvLsjjVKY/edit?gid=214826419#gid=214826419.] Still about 690 remaining. Most of these are SOWs with a blank Status on the Ironclad Contract though. Maybe this is why they weren't picked up in the original audit.

Aside from these, about 50 are IC Contracts related to a Legal Req where the CLM stage is not equal to Signature Obtained or Completed" |
| `customfield_20217` | [CHART] Date of First Response | "2026-07-23T12:18:42.701+0000" |
| `customfield_20218` | [CHART] Time in Status | "3_*:*_1_*:*_0_*|*_10031_*:*_1_*:*_1722311922" |
| `customfield_22455` | Remediation Instance ID | "None" |
| `customfield_22456` | Remediation Instance Name | "None" |
| `customfield_22457` | Remediation Instance Owner | "None" |
| `customfield_22458` | Remediation Instance Updater | "None" |
| `customfield_22459` | Description of remediation instance | "None" |
| `customfield_22460` | Remediated Pattern ID | "None" |
| `customfield_22461` | Remediated Instance ID | "None" |
| `customfield_22462` | Kill Scope | "None" |
| `customfield_22463` | Safe Quarantine | "None" |
| `customfield_22464` | Forced Quarantine | "None" |
| `customfield_22465` | Registry Persistence Removal | "None" |
| `customfield_22467` | Channel File Priority | "None" |
| `customfield_22604` | originId | "4112355" |
| `customfield_22605` | openTasksCount | "0.0" |
| `customfield_22606` | closedTasksCount | "0.0" |
| `customfield_22607` | allTasksCount | "0.0" |
| `customfield_22609` | Stoplight | Green |
| `customfield_22619` | End Products | "replaceme" |
| `customfield_22620` | Value Proposition | "replaceme" |
| `customfield_22625` | Providing Team | "replaceme" |
| `customfield_22626` | Required Capabilities | "replaceme" |
| `customfield_22627` | Required Capacity | "replaceme" |
| `customfield_22631` | Committing Manager | replaceme |
| `customfield_22740` | Sales Connector | None Assigned |
| `customfield_23017` | Vendor Status | Needs Review |
| `customfield_23023` | Integration Status | Sourcing |
| `customfield_23026` | License Status | Needs Review |
| `customfield_23401` | Falcon Apps & Modules | ['No Module(s)'] |
| `customfield_23521` | Partner Agent Required | ['No'] |
| `customfield_23543` | Feature Flag Details | "Feature Flag Name: 

Component: ex. Microservice/UI/Sensor/VM" |
| `customfield_23601` | Deployment Date | "2026-10-07" |
| `customfield_23709` | Detections Triggered | 0.0 |
| `customfield_23710` | Notifications sent via email or slack | 0.0 |
| `customfield_23711` | Detections referred to OW | 0.0 |
| `customfield_23900` | FXE Customer Type | Subscription |
| `customfield_24536` | QA Assignee | None Assigned |
| `customfield_24917` | RCA | Not Needed |
| `customfield_25141` | UX Design Assigned | None Assigned |
| `customfield_30016` | Technical Design Review Status | Not Started |
| `customfield_30017` | Test Plan Review Status | Not Started |
| `customfield_30213` | AI Required? | No |
| `lastViewed` | Last Viewed | "2026-09-29T06:34:45.338+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Jitesh Bhatia - 2026-07-23T12:18:42.701+0000

Analysis - https://docs.google.com/document/d/1GIyztfLD_BpBtWZ8KsEKVTKSSDWebo-pqr2Pk54opkg/edit?usp=sharing
### Jitesh Bhatia - 2026-07-23T15:34:43.576+0000

[~eglass] to review above spreadsheet with Liz Kelly before we proceed with any further action on this ticket.
### Liz Glass - 2026-08-27T19:57:20.603+0000

[https://docs.google.com/spreadsheets/d/15R-5RFiPBGp5NuLgVZwAa87ZPgO0TPQY7xcEraj3YtI/edit?gid=0#gid=0] [~sjohnson03] has approved the IT team to delete the contracts on this spreadsheet 8/27/26
### Liz Glass - 2026-08-27T20:01:31.136+0000

[https://docs.google.com/spreadsheets/d/1jXWE18lU4fs2seKpbcbwmpI-H1eSBq41xdS46YVC9zY/edit?gid=2078615786#gid=2078615786] [~sjohnson03] has approved the IT team to delete the contracts on this spreadsheet where the Current CLM Stage does not equal Signature Obtained or Completed AND IT action is move to active
### Jitesh Bhatia - 2026-08-27T20:53:08.984+0000

[~eglass] first sheet deletion is complete - [https://docs.google.com/spreadsheets/d/15R-5RFiPBGp5NuLgVZwAa87ZPgO0TPQY7xcEraj3YtI/edit?gid=0#gid=0]
### Jitesh Bhatia - 2026-08-27T21:30:01.684+0000

[~eglass] second sheet deletion is complete - [https://docs.google.com/spreadsheets/d/1jXWE18lU4fs2seKpbcbwmpI-H1eSBq41xdS46YVC9zY/edit?gid=2078615786#gid=2078615786]
### Liz Glass - 2026-09-03T15:48:02.578+0000

[~jbhatia] can we run a final report to determine that no contracts exist with a request form CLM stage not equal to Signature Obtained or Completed? 
### Jitesh Bhatia - 2026-09-03T18:02:10.597+0000

[~eglass] here's the updated report - [https://docs.google.com/spreadsheets/d/1-xvi29p2o8LeXPxXKwT2xVg8oUCDk_Gt7uWvLsjjVKY/edit?gid=214826419#gid=214826419.] Still about 690 remaining. Most of these are SOWs with a blank Status on the Ironclad Contract though. Maybe this is why they weren't picked up in the original audit.

Aside from these, about 50 are IC Contracts related to a Legal Req where the CLM stage is not equal to Signature Obtained or Completed
