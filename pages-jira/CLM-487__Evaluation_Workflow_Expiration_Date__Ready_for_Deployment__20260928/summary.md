---
title: "Evaluation Workflow: Expiration Date Help Text"
jira_key: "CLM-487"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "Ready for Deployment"
jira_priority: "Medium"
jira_url: "https://jira.cs.sys/browse/CLM-487"
jira_assignee: "Vikas Chauhan"
jira_reporter: "Liz Glass"
jira_created: "2026-08-20T16:11:37.315+0000"
jira_updated: "2026-09-28T16:08:46.533+0000"
pulled_at: "2026-09-28T16:44:09.289880+00:00"
attachment_count: 2
attachment_failures: 0
---

# CLM-487: Evaluation Workflow: Expiration Date Help Text

**Type**: Task
**Status**: Ready for Deployment
**Priority**: Medium
**Assignee**: Vikas Chauhan
**Reporter**: Liz Glass
**Created**: 2026-08-20T16:11:37.315+0000
**Updated**: 2026-09-28T16:08:46.533+0000
**URL**: https://jira.cs.sys/browse/CLM-487

**Labels**: legal
**Components**: Ironclad

## Description

{panel:title=Background|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
Help text is required on the Expiration Date Override field in the Eval workflow so that Legal knows the Expiration Date will default to 15 days from the Effective Date if the override isn't populated.
{panel}
{panel:title=User Story|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
*As a* legal user

*So that* I can make informed decisions when setting contract expiration dates

*I want to* see clear help text near the override date field in Ironclad that explains the default expiration logic and when to use the override functionality
{panel}
{panel:title=Acceptance Criteria|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 * [ ] Help text is positioned as close as possible to the override date field
 * [ ] Text clearly explains that the default expiration date is 15 days from the effective date
 * [ ] Text instructs users to populate the override date field only if an adjustment is required
 * [ ] Draft help text is created and documented for legal team review
 * [ ] Legal team approves the final help text before implementation
 * [ ] Help text is implemented and displays consistently across all relevant screens
 * [ ] Text is easily readable and follows UI/UX standards{panel}
{panel:title=Solution Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 * Add the following help text to the "Expiration Date Override" field in the Eval workflow in Ironclad: _"Default expiration date is automatically set to 15 days from the effective date. Only populate the override date field if a different expiration date is required."_{panel}
{panel:title=Definition of Done|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 * Draft help text has been reviewed and approved by the legal team
 * Help text is implemented and visible to sales users
 * Legal users can clearly understand when and how to use the override date field
 * No impact to existing default expiration date calculation logic{panel}

## Linked Issues

| Relationship | Issue | Summary | Status |
|--------------|-------|---------|--------|
| tested by | CLM-513 | QAT - Evaluation Workflow: Expiration Date Help Text | Done |
| tested by | CLM-514 | UAT - Evaluation Workflow: Expiration Date Help Text | Done |

## Attachments

| Filename | Size | Uploaded By | Date |
|----------|------|-------------|------|
| CLM-487_UAT.png | 624.0 KB | Mohanish More | 2026-09-22 |
| CLM-487_QAT.png | 627.5 KB | Mohanish More | 2026-09-22 |

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 1.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@5dd73602[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@2ba3461f[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|hypevc:07c3n1zo" |
| `customfield_11700` | Time in Status | "null" |
| `customfield_11701` | Date of First Response | "2026-09-21T08:52:27.402+0000" |
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
| `customfield_17641` | Last Comment | "This ticket has been tested and verified on QAT and UAT.
Please refer to the attachments for more information.

cc: [~vchauhan02] [~eglass] " |
| `customfield_20217` | [CHART] Date of First Response | "2026-09-21T08:52:27.402+0000" |
| `customfield_20218` | [CHART] Time in Status | "null" |
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
| `customfield_22604` | originId | "4293204" |
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
| `customfield_23601` | Deployment Date | "2026-09-29" |
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
| `lastViewed` | Last Viewed | "2026-09-23T06:02:10.690+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Vikas Chauhan - 2026-09-21T08:52:27.402+0000

Required changes are on QAT and UAT.

CC: [~mmore] - You can test it on QAT and UAT
### Mohanish More - 2026-09-22T07:38:13.136+0000

This ticket has been tested and verified on QAT and UAT.
Please refer to the attachments for more information.

cc: [~vchauhan02] [~eglass] 
