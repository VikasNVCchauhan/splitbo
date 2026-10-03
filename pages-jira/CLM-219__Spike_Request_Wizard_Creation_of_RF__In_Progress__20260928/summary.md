---
title: "Spike | Request Wizard: Creation of RF prior to uploading a document"
jira_key: "CLM-219"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "In Progress"
jira_priority: "Low"
jira_url: "https://jira.cs.sys/browse/CLM-219"
jira_assignee: "Jitesh Bhatia"
jira_reporter: "Liz Glass"
jira_created: "2026-03-02T22:47:26.081+0000"
jira_updated: "2026-09-28T16:08:47.462+0000"
pulled_at: "2026-09-28T16:44:04.731082+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-219: Spike | Request Wizard: Creation of RF prior to uploading a document

**Type**: Task
**Status**: In Progress
**Priority**: Low
**Assignee**: Jitesh Bhatia
**Reporter**: Liz Glass
**Created**: 2026-03-02T22:47:26.081+0000
**Updated**: 2026-09-28T16:08:47.462+0000
**URL**: https://jira.cs.sys/browse/CLM-219

**Labels**: legal
**Components**: Salesforce

## Description

 
{panel:title=Background|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
Sales users are beginning the request process by providing information via the Wizard but in the case of the document upload path, the request form is created prior to the submission of the document. This can result in a request form being created with no associated workflow. 

Requirement: Explore a solution that does not allow for the creation of the RF without a trigger for simultaneous workflow creation. Also investigate triggering the Workflow via the API instead of the launch form so that we bypass the tab and occasional user signins to Ironclad.
{panel}
{panel:title=User Story|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
As a Legal user
I want the Request Form creation to be atomic with Workflow creation when documents are uploaded via the Wizard
So that we prevent orphaned Request Forms that have no associated workflows
{panel}
{panel:title=Acceptance Criteria|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
1. Document Current Implementation
    - Map the current Wizard document upload flow (sequence diagram or flowchart)
    - Identify exact point where Request Form is created vs. Workflow creation
    - Identify which classes/triggers/flows are involved in the process
    - Document timing gaps and failure scenarios that cause orphaned records
  2. Assess Data Impact
    - Query and quantify existing orphaned Request Forms (no associated Workflow)
    - Identify patterns: timeframes, users, document types affected
    - Determine business impact and urgency
  3. Evaluate Technical Solutions
    - Option A: Refactor to use LWC for atomic creation
    - Option B: Implement deletion mechanism for Requests without a workflow
    - Option C: Defer Request Form creation until after document upload confirmation
    - Option D: Use Platform Events with failure recovery mechanism
    - Document pros/cons, implementation complexity, and risks for each option
  4. Identify Standards Compliance
    - Review relevant coding standards (Service/UoW layer patterns)
    - Ensure proposed solutions align with CrowdStrike architecture
    - Check trigger framework impact and ordering considerations
  5. Define Remediation Strategy
    - Propose approach for handling existing orphaned Request Forms
    - Document data cleanup requirements and risks
  6. Create Implementation Recommendation
    - Recommend preferred technical solution with justification
    - Provide high-level implementation steps
    - Estimate implementation complexity (S/M/L/XL)
    - Identify dependencies and risks
{panel}
{panel:title=Tech Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 *  {panel}
{panel:title=Testing Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 *  {panel}

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 2.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@47d50f61[activatedDate=2026-07-23T15:46:21.488Z,autoStartStop=false,completeDate=2026-08-03T20:59:14.090Z,endDate=2026-07-29T20:53:00.000Z,goal=,id=18852,incompleteIssuesDestinationId=<null>,name=CLM Sprint 18,rapidViewId=9801,sequence=18852,startDate=2026-07-15T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@3b15b0b3[activatedDate=2026-08-03T21:00:06.384Z,autoStartStop=false,completeDate=2026-08-20T12:35:48.048Z,endDate=2026-08-19T20:53:00.000Z,goal=<null>,id=18853,incompleteIssuesDestinationId=<null>,name=CLM Sprint 19,rapidViewId=9801,sequence=18853,startDate=2026-07-29T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@7294d430[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4379d07a[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@53bdc220[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|hypevc:07c3nai" |
| `customfield_11700` | Time in Status | "null" |
| `customfield_11701` | Date of First Response | "2026-03-12T16:31:43.704+0000" |
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
| `customfield_17641` | Last Comment | "Andrew suggesting that this would possibly need significant redesign in the Wizard. Maybe an LWC that combines the Request creation and file upload in one place" |
| `customfield_20217` | [CHART] Date of First Response | "2026-03-12T16:31:43.704+0000" |
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
| `customfield_22604` | originId | "3787783" |
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
| `customfield_23533` | Tech Writer Assigned | None Assigned |
| `customfield_23543` | Feature Flag Details | "Feature Flag Name: 

Component: ex. Microservice/UI/Sensor/VM" |
| `customfield_23601` | Deployment Date | "2026-10-13" |
| `customfield_23707` | Hunt leads suppressed by new rules or updates | 0.0 |
| `customfield_23708` | Hunt leads investigated | 0.0 |
| `customfield_23709` | Detections Triggered | 0.0 |
| `customfield_23710` | Notifications sent via email or slack | 0.0 |
| `customfield_23711` | Detections referred to OW | 0.0 |
| `customfield_23900` | FXE Customer Type | Subscription |
| `customfield_24536` | QA Assignee | None Assigned |
| `customfield_24917` | RCA | Not Needed |
| `customfield_25141` | UX Design Assigned | None Assigned |
| `customfield_30016` | Technical Design Review Status | Not Started |
| `customfield_30017` | Test Plan Review Status | Not Started |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Jitesh Bhatia - 2026-03-12T16:31:43.704+0000

[~jbhatia] to investigate and add solution notes
### Jitesh Bhatia - 2026-03-12T16:33:16.144+0000

Andrew suggesting that this would possibly need significant redesign in the Wizard. Maybe an LWC that combines the Request creation and file upload in one place
