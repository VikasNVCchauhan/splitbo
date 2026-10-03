---
title: "MPA Evaluation and Updates"
jira_key: "CLM-516"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "In Progress"
jira_priority: "High"
jira_url: "https://jira.cs.sys/browse/CLM-516"
jira_assignee: "Liz Glass"
jira_reporter: "Liz Glass"
jira_created: "2026-09-22T20:21:29.880+0000"
jira_updated: "2026-09-28T16:09:54.581+0000"
pulled_at: "2026-09-28T16:44:05.325152+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-516: MPA Evaluation and Updates

**Type**: Task
**Status**: In Progress
**Priority**: High
**Assignee**: Liz Glass
**Reporter**: Liz Glass
**Created**: 2026-09-22T20:21:29.880+0000
**Updated**: 2026-09-28T16:09:54.581+0000
**URL**: https://jira.cs.sys/browse/CLM-516

**Labels**: Legal, datamigration
**Components**: Ironclad, Salesforce

## Description

*As a* CLM Administrator
*I want* to leverage AI tools to validate MPA contract attributes against actual contract language
*So that* we can ensure data accuracy in our migrated records before system implementation
h2. Acceptance Criteria

*Data Preparation:*
 * [ ] Spreadsheet of MPA attributes is compiled from migrated records
 * [ ] Contract documents are accessible for AI analysis
 * [ ] Attribute validation criteria are clearly defined

*AI-Powered Analysis:*
 * [ ] Claude (or similar AI tool) is configured to read contract documents
 * [ ] AI tool extracts key attributes from each contract
 * [ ] System compares extracted data against existing spreadsheet attributes
 * [ ] Discrepancies are flagged and documented with specific contract references

*Legal Review Process:*
 * [ ] Legal team receives analysis results with flagged discrepancies
 * [ ] Legal team reviews AI findings against actual contract language
 * [ ] Legal team approves or rejects suggested attribute corrections
 * [ ] Approval decisions are documented with rationale

*Data Updates:*
 * [ ] Approved attribute corrections are applied to the spreadsheet
 * [ ] Updated records are validated for completeness and accuracy
 * [ ] Final dataset is prepared for system upload

h2. Definition of Done
 * [ ] All MPA contracts have been analyzed by AI tool
 * [ ] Legal team has reviewed and approved/rejected all suggested changes
 * [ ] Spreadsheet attributes accurately reflect contract terms
 * [ ] Data quality validation is completed
 * [ ] Updated MPA attributes are ready for system implementation

*Dependencies:*
 * Access to migrated contract documents
 * AI tool configuration and access
 * Legal team availability for review cycles

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 4.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@5dd73602[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@2ba3461f[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|ig8phg:" |
| `customfield_11701` | Date of First Response | "2026-09-24T19:06:07.235+0000" |
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
| `customfield_17641` | Last Comment | "*This evaluation has been completed:* [https://docs.google.com/spreadsheets/d/1l0UBWUH59vp2rE8e4BBW4LQKOBnleReN/edit?usp=sharing&ouid=104218094855923683745&rtpof=true&sd=true]

CC: [~eglass] , [~sjohnson03] " |
| `customfield_20217` | [CHART] Date of First Response | "2026-09-24T19:06:07.235+0000" |
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
| `customfield_22604` | originId | "4386642" |
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
| `customfield_23601` | Deployment Date | "2026-10-13" |
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
| `lastViewed` | Last Viewed | "2026-09-27T12:46:55.942+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Vikas Chauhan - 2026-09-24T19:06:07.235+0000

*This evaluation has been completed:* [https://docs.google.com/spreadsheets/d/1l0UBWUH59vp2rE8e4BBW4LQKOBnleReN/edit?usp=sharing&ouid=104218094855923683745&rtpof=true&sd=true]

CC: [~eglass] , [~sjohnson03] 
