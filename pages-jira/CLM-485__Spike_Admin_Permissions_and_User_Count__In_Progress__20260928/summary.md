---
title: "Spike: Admin Permissions and User Count"
jira_key: "CLM-485"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "In Progress"
jira_priority: "Medium"
jira_url: "https://jira.cs.sys/browse/CLM-485"
jira_assignee: "Vikas Chauhan"
jira_reporter: "Liz Glass"
jira_created: "2026-08-20T16:00:09.018+0000"
jira_updated: "2026-09-28T16:08:53.979+0000"
pulled_at: "2026-09-28T16:44:04.975549+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-485: Spike: Admin Permissions and User Count

**Type**: Task
**Status**: In Progress
**Priority**: Medium
**Assignee**: Vikas Chauhan
**Reporter**: Liz Glass
**Created**: 2026-08-20T16:00:09.018+0000
**Updated**: 2026-09-28T16:08:53.979+0000
**URL**: https://jira.cs.sys/browse/CLM-485

**Labels**: ProServ_Ops, legal
**Components**: Ironclad

## Description

*Issue/Impact/Population:*
Current admin group permissions are overly broad, granting unnecessary administrative access to users who don't require full admin functions. This creates security risks and potential for accidental or unauthorized changes, particularly within workflow systems, affecting users across all environments (dev, QAT, UAT, and prod) who have been assigned to admin groups.

*Research Objective:*
Evaluate current admin user permissions and group assignments to determine if a separate, more restrictive permission group should be created that follows the principle of least privilege access.

*Research Questions:*
 * [ ] What specific admin permissions are currently granted to the existing admin group?
 * [ ] Who are the current members of admin groups across all environments (dev, QAT, UAT, prod)?
 * [ ] What admin functions does each user actually need to perform their job responsibilities?
 * [ ] What are the security risks associated with current over-privileged access, especially for workflows?
 * [ ] What would be the technical requirements for creating a new restricted admin group?
 * [ ] How would permission changes impact existing user workflows and daily operations?
 * [ ] What is the effort required to migrate users to appropriate permission levels?

*Deliverables:*
 * Current state permission audit across all environments
 * Risk assessment of existing access levels
 * Recommended permission group structure
 * User-to-permission mapping based on actual needs
 * Migration plan and effort estimation

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 2.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@490db714[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@41af131f[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|ift85c:" |
| `customfield_11700` | Time in Status | "3_*:*_1_*:*_0_*|*_10031_*:*_1_*:*_2295222632" |
| `customfield_11701` | Date of First Response | "2026-09-16T13:52:26.814+0000" |
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
| `customfield_17641` | Last Comment | "[~eglass] - Analysis has been completed: https://docs.google.com/spreadsheets/d/1XL6wzNHZNHiDn1qiYr9XENK7mHgXi4hr/edit?usp=sharing&ouid=104218094855923683745&rtpof=true&sd=true" |
| `customfield_20217` | [CHART] Date of First Response | "2026-09-16T13:52:26.814+0000" |
| `customfield_20218` | [CHART] Time in Status | "3_*:*_1_*:*_0_*|*_10031_*:*_1_*:*_2295222632" |
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
| `customfield_22604` | originId | "4293090" |
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
| `lastViewed` | Last Viewed | "2026-09-28T14:33:34.905+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Vikas Chauhan - 2026-09-16T13:52:26.814+0000

[~eglass] - Analysis has been completed: https://docs.google.com/spreadsheets/d/1XL6wzNHZNHiDn1qiYr9XENK7mHgXi4hr/edit?usp=sharing&ouid=104218094855923683745&rtpof=true&sd=true
