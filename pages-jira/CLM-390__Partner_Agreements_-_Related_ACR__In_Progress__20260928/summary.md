---
title: "Partner Agreements - Related ACR"
jira_key: "CLM-390"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "In Progress"
jira_priority: "Medium"
jira_url: "https://jira.cs.sys/browse/CLM-390"
jira_assignee: "Liz Glass"
jira_reporter: "Raymond Du"
jira_created: "2026-05-21T17:56:18.333+0000"
jira_updated: "2026-09-28T16:08:50.413+0000"
pulled_at: "2026-09-28T16:44:05.010857+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-390: Partner Agreements - Related ACR

**Type**: Task
**Status**: In Progress
**Priority**: Medium
**Assignee**: Liz Glass
**Reporter**: Raymond Du
**Created**: 2026-05-21T17:56:18.333+0000
**Updated**: 2026-09-28T16:08:50.413+0000
**URL**: https://jira.cs.sys/browse/CLM-390

**Labels**: Alliances, legal
**Components**: Salesforce

## Description

{panel:title=Background|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
Currently, when Alliances Operations and Channels Account Managers create Legal requests through the Salesforce wizard, they must manually enter authorized counterparty territory information. This manual process is time-consuming and prone to inconsistencies, especially when the territory associations already exist in related Account Contact Relationship (ACR) records.
{panel}
{panel:title=User Story|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
*As an* alliances ops and channels account manager
*I want to* select a pre-existing ACR from a lookup field in the Salesforce request wizard (optional field)
*So that* I can automatically populate authorized counterparty territories associated with the selected ACR for the current account, reducing manual entry and ensuring consistency
{panel}
{panel:title=Acceptance Criteria|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
h3. Core Functionality
 * [ ] Request wizard displays a searchable lookup field for existing ACRs
 * [ ] ACR selection is filtered by relevance to the current account context (account hierarchy, region, partner type)
 * [ ] Upon ACR selection, authorized counterparty territories are automatically populated in the request form
 * [ ] User can see which territories were imported from the selected ACR (visual indicator/audit trail)
 * [ ] If ACR is not optionally filled, the user can relate the Legal Request to the ACR manually from the Request Form (lookup field)

h3. Data Integration
 * [ ] {*}Request Form{*}: New field to store territory data imported from ACR
 * [ ] {*}Ironclad Integration{*}:
 ** Sync territory data from Request Form to Ironclad Properties
 ** Territory field remains editable in Ironclad Properties
 ** Make required field for archival {*}{{*}}Liz need to check with Michelle Cline on N/A option when the option is global and there are no listed territories{{*}}{*}
 ** Write back finalized territory data to update source ACR record. If finalized territories are NULL, do NOT overwrite the ACR. 
 ** Store Ironclad contract ID on ACR record for traceability
 ** Store territories selection on the Ironclad Contract record

h2. Open Questions
 * {*}Retroactive Application{*}: Confirm that this will not be retroactive. {panel}
{panel:title=Tech Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 * Updates should be made in the Sub_RequestWizard_Legal flow
 * Add a new optional "Record Lookup Component" to the "Legal Request" screen that enables the user to search for and select an ACR Request Form under the selected Account
 * Only display the lookup if the Legal Request Type = partner
 * Populate the selected ACR into the Related_Request__c field on the Legal Request
 * When the Ironclad Contract is updated with the Request Form, populate the contract on the Ironclad_Contract__c lookup field on the ACR
 * Write the data from the Ironclad Contract's Counterparty_Sales_Territory_{_}c field to the Partner_Territory{_}_c field on the ACR
 ** Only write over the data if Counterparty_Sales_Territory__c != null
 ** The Counterparty_Sales_Territory_{_}c will be stored as comma separated, so this needs to be converted to semi colon delimited to populate on the Partner_Territory{_}_c field. Example - https://crowdstrike--qat.sandbox.lightning.force.com/lightning/r/ironclad__Ironclad_Contract__c/a6aNq0000009RKLIA2/view{panel}
{panel:title=Testing Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 
{panel}
 

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 8.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@4b0d18dd[activatedDate=2026-06-29T14:21:07.024Z,autoStartStop=false,completeDate=2026-07-01T19:12:38.395Z,endDate=2026-07-01T20:53:00.000Z,goal=<null>,id=18642,incompleteIssuesDestinationId=<null>,name=CLM Sprint 16,rapidViewId=9801,sequence=18642,startDate=2026-06-17T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6d199b60[activatedDate=2026-07-01T19:13:06.208Z,autoStartStop=false,completeDate=2026-07-23T15:45:55.222Z,endDate=2026-07-15T20:53:00.000Z,goal=,id=18851,incompleteIssuesDestinationId=<null>,name=CLM Sprint 17,rapidViewId=9801,sequence=18851,startDate=2026-07-01T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@5e8b6d8a[activatedDate=2026-07-23T15:46:21.488Z,autoStartStop=false,completeDate=2026-08-03T20:59:14.090Z,endDate=2026-07-29T20:53:00.000Z,goal=,id=18852,incompleteIssuesDestinationId=<null>,name=CLM Sprint 18,rapidViewId=9801,sequence=18852,startDate=2026-07-15T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6b04b452[activatedDate=2026-08-03T21:00:06.384Z,autoStartStop=false,completeDate=2026-08-20T12:35:48.048Z,endDate=2026-08-19T20:53:00.000Z,goal=<null>,id=18853,incompleteIssuesDestinationId=<null>,name=CLM Sprint 19,rapidViewId=9801,sequence=18853,startDate=2026-07-29T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4f722678[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]'] |
| `customfield_11300` | Rank | "2|iekc80:" |
| `customfield_11700` | Time in Status | "null" |
| `customfield_11701` | Date of First Response | "2026-08-06T13:57:32.990+0000" |
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
| `customfield_17641` | Last Comment | "[~eglass] - Are we creating a separate ticket for the country list discrepancy, or how do we want to handle it? Today, I close the CCR without deployment for the same Ironclad counterparty Jira ticket, which is currently sitting in a queue. Could you confirm the next step?" |
| `customfield_20217` | [CHART] Date of First Response | "2026-08-06T13:57:32.990+0000" |
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
| `customfield_22604` | originId | "4028178" |
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
| `customfield_23601` | Deployment Date | "2026-10-06" |
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
| `lastViewed` | Last Viewed | "2026-09-17T11:50:57.596+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Jitesh Bhatia - 2026-08-06T13:57:32.990+0000

[~eglass] could we limit the ACR search to ACRs under the Account itself? Searching based on account hierarchy, region, partner type will significantly increase the work required on this ticket.
### Jitesh Bhatia - 2026-08-06T15:23:25.604+0000

Ironclad work required for this - CLM-469
### Vikas Chauhan - 2026-08-19T07:55:28.949+0000

[~lmeghani] Let me know once you'll be done with the SF side of work on this. Then I'll create that Inbound sync mapping in Ironclad for the testing  CLM-469
### svc_it_gitlab_jira - 2026-08-25T08:35:17.372+0000

[Lakhan Meghani|https://gitlab.cs.sys/lakhan.meghani] mentioned this issue in [a merge request|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/merge_requests/8032] of [CrowdStrike / GTM / SFDC / Commercial|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial] on branch [feature/US-0040781|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/tree/feature/US-0040781]:{quote}US-0040781 [CLM-390]: Partner Agreements - Related ACR{quote}
### Andrew Yoder - 2026-09-03T13:12:45.693+0000

[~eglass] - Here are the findings around the country naming alignment we discussed yesterday.  Any in the first sheet will not be able to sync back to the ACR territories until the names are aligned.  The way it's currently implemented, any mismatches would just be skipped.

[https://docs.google.com/spreadsheets/d/1CH69vMCi-GpJ6Qv_Fg4WBr0cZRd6yoARnwnvbH0ldMY/edit?usp=sharing] 
### Vikas Chauhan - 2026-09-16T09:50:59.372+0000

[~eglass] - Are we creating a separate ticket for the country list discrepancy, or how do we want to handle it? Today, I close the CCR without deployment for the same Ironclad counterparty Jira ticket, which is currently sitting in a queue. Could you confirm the next step?
