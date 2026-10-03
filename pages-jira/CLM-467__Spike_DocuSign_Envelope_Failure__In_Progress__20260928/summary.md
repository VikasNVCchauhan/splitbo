---
title: "Spike: DocuSign Envelope Failure Notifications"
jira_key: "CLM-467"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "In Progress"
jira_priority: "High"
jira_url: "https://jira.cs.sys/browse/CLM-467"
jira_assignee: "Jitesh Bhatia"
jira_reporter: "Liz Glass"
jira_created: "2026-08-03T21:56:17.560+0000"
jira_updated: "2026-09-28T16:08:42.005+0000"
pulled_at: "2026-09-28T16:44:08.711577+00:00"
attachment_count: 2
attachment_failures: 0
---

# CLM-467: Spike: DocuSign Envelope Failure Notifications

**Type**: Task
**Status**: In Progress
**Priority**: High
**Assignee**: Jitesh Bhatia
**Reporter**: Liz Glass
**Created**: 2026-08-03T21:56:17.560+0000
**Updated**: 2026-09-28T16:08:42.005+0000
**URL**: https://jira.cs.sys/browse/CLM-467

**Labels**: ProServ_Ops, legal
**Components**: Docusign, Ironclad

## Description

h2. User Story

*As a* legal team member
*I want to* be automatically notified when DocuSign envelopes fail due to email address issues or other problems
*So that* I can quickly resolve issues and prevent deal delays without having to manually monitor envelope status
h3. Acceptance Criteria

*Phase 1: Investigation & Root Cause Analysis*
 # *GIVEN* DocuSign envelope failures occur
*WHEN* I investigate the current notification system
*THEN* I should document:

 ** Types of failures not currently captured in workflow activity
 ** Current DocuSign webhook/API integration points
 ** Gap analysis of failure scenarios vs. notifications sent
 # *GIVEN* email address issues cause envelope failures
*WHEN* the failure occurs
*THEN* the system should capture the specific error details and failure reason

*Phase 2: Notification Implementation*
      3. *GIVEN* a DocuSign envelope fails for any reason
           *WHEN* the failure is detected by the system
           *THEN* the legal owner should receive an immediate email notification with:
 * Workflow/deal identifier
 * Specific failure reason (e.g., invalid email address)
 * Envelope details

 # *GIVEN* a DocuSign envelope failure occurs
*WHEN* the system processes the failure
*THEN* the failure details should be logged in the workflow activity section for audit trail

 
h3. Definition of Done
 * [ ] Root cause analysis completed for current notification gaps
 * [ ] DocuSign integration enhanced to capture all failure types
 * [ ] Email notification system implemented for legal owners
 * [ ] Workflow activity logging updated to show envelope failures
 * [ ] Testing completed with various failure scenarios

h3. Technical Investigation Tasks
 * [ ] Audit current DocuSign webhook configurations
 * [ ] Review DocuSign API error response handling
 * [ ] Identify integration points where failures may be lost
 * [ ] Map current notification triggers vs. actual failure events
 * [ ] Assess system capacity for real-time failure detection

h3. Success Metrics
 * Zero unnotified envelope failures
 * Reduced average time to failure resolution
 * Improved legal team satisfaction with workflow visibility

## Attachments

| Filename | Size | Uploaded By | Date |
|----------|------|-------------|------|
| Screenshot 2026-09-15 at 10.46.30 AM.png | 416.7 KB | Jitesh Bhatia | 2026-09-15 |
| Screenshot 2026-09-15 at 8.23.20 AM.png | 353.4 KB | Jitesh Bhatia | 2026-09-15 |

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 4.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@4f722678[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6e91766d[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6b73a108[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|hypevc:07c3n1wo" |
| `customfield_11701` | Date of First Response | "2026-09-15T15:29:44.743+0000" |
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
| `customfield_17641` | Last Comment | "Looks like the delivery failure notification gets sent to the sender by default - https://support.docusign.com/s/articles/Why-am-I-still-receiving-delivery-failure-notifications-after-correcting-a-recipient-s-e-mail-address?language=en_US" |
| `customfield_20217` | [CHART] Date of First Response | "2026-09-15T15:29:44.743+0000" |
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
| `customfield_22604` | originId | "4241218" |
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
| `lastViewed` | Last Viewed | "2026-09-15T17:44:47.702+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Jitesh Bhatia - 2026-09-15T15:29:44.743+0000

Submitted support ticket regarding this issue - [https://support.ironcladapp.com/hc/en-us/requests/113879]

Example of delivery failure in DocuSign that's not captured on the Ironclad workflow: !Screenshot 2026-09-15 at 8.23.20 AM.png|thumbnail!

CC: [~eglass] [~vchauhan02] 
### Jitesh Bhatia - 2026-09-15T17:47:29.809+0000

Response from Ironclad support:  !Screenshot 2026-09-15 at 10.46.30 AM.png|width=977,height=600!

CC: [~eglass] [~vchauhan02] 
### Jitesh Bhatia - 2026-09-16T16:08:44.051+0000

See if it's possible to configure a notification in DocuSign when one of these errors happen. Likely we'd want these notification to go to someone on our team or Julia's team instead of Legal.
### Jitesh Bhatia - 2026-09-21T19:36:05.318+0000

Looks like the delivery failure notification gets sent to the sender by default - https://support.docusign.com/s/articles/Why-am-I-still-receiving-delivery-failure-notifications-after-correcting-a-recipient-s-e-mail-address?language=en_US
