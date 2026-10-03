---
title: "Backfill Falcon Shield for MPA IC Contract Records "
jira_key: "CLM-449"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "To Do"
jira_priority: "Medium"
jira_url: "https://jira.cs.sys/browse/CLM-449"
jira_assignee: "Jitesh Bhatia"
jira_reporter: "Liz Glass"
jira_created: "2026-07-14T19:42:21.376+0000"
jira_updated: "2026-09-28T16:08:51.444+0000"
pulled_at: "2026-09-28T16:44:05.241342+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-449: Backfill Falcon Shield for MPA IC Contract Records 

**Type**: Task
**Status**: To Do
**Priority**: Medium
**Assignee**: Jitesh Bhatia
**Reporter**: Liz Glass
**Created**: 2026-07-14T19:42:21.376+0000
**Updated**: 2026-09-28T16:08:51.444+0000
**URL**: https://jira.cs.sys/browse/CLM-449

**Labels**: legal
**Components**: Ironclad, Salesforce

## Description

h2. User Story

*As a* legal team member or contract administrator
*I want* all MPA negotiated contract records with no geo restrictions and authorized EPP to automatically include Falcon Shield as an available product
*So that* our contract records are complete and accurate, ensuring Falcon Shield is properly covered under the appropriate MPAs
h2. Acceptance Criteria
 * *Given* an MPA contract record exists with no geographical restrictions
 * *And* the MPA is authorized for EPP (Endpoint Protection Platform)
 * *When* I review the covered products and services section
 * *Then* Falcon Shield should be listed as an available product
 * *And* this should apply to all existing MPA records meeting these criteria (data remediation)
 * *And* this should automatically apply to new MPA records that meet these criteria going forward
 * *And* the addition of Falcon Shield should not affect other existing products/services in the MPA

h2. Additional Details

*Scope:*
 * Existing MPA records requiring retroactive update

*Criteria for Falcon Shield inclusion:*
 * No geo restrictions on the MPA
 * EPP authorization present

*Priority:* High (ensures contract compliance and product coverage accuracy)

*Success Metrics:*
 * All qualifying MPA records updated to include Falcon Shield

 

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 2.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@6b04b452[activatedDate=2026-08-03T21:00:06.384Z,autoStartStop=false,completeDate=2026-08-20T12:35:48.048Z,endDate=2026-08-19T20:53:00.000Z,goal=<null>,id=18853,incompleteIssuesDestinationId=<null>,name=CLM Sprint 19,rapidViewId=9801,sequence=18853,startDate=2026-07-29T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4f722678[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6e91766d[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6b73a108[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|ifb2c8:" |
| `customfield_13400` | Development | "{}" |
| `customfield_14221` | Template | "{}" |
| `customfield_14410` | Notification Count | 0 |
| `customfield_15236` | Deployed to CIDs | "None" |
| `customfield_15238` | PIR | ['PIRS_GO_HERE'] |
| `customfield_15606` | MI | "null" |
| `customfield_15611` | Exploit Type | "null" |
| `customfield_16009` | Report ID | "null" |
| `customfield_17605` | Coordinating Architect (CAT) Effort | TBD |
| `customfield_17608` | Product Manager (PM) | None Assigned |
| `customfield_17629` | Crypto Justification | Expiration |
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
| `customfield_22604` | originId | "4185076" |
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
| `customfield_23601` | Deployment Date | "2026-10-01" |
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
| `progress` | Progress | ['progress', 'total'] |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |