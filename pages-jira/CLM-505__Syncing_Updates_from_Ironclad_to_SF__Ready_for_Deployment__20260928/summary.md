---
title: "Syncing Updates from Ironclad to SF Contract Record"
jira_key: "CLM-505"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "Ready for Deployment"
jira_priority: "High"
jira_url: "https://jira.cs.sys/browse/CLM-505"
jira_assignee: "Jitesh Bhatia"
jira_reporter: "Liz Glass"
jira_created: "2026-09-02T21:43:16.932+0000"
jira_updated: "2026-09-28T16:35:39.591+0000"
pulled_at: "2026-09-28T16:44:05.083614+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-505: Syncing Updates from Ironclad to SF Contract Record

**Type**: Task
**Status**: Ready for Deployment
**Priority**: High
**Assignee**: Jitesh Bhatia
**Reporter**: Liz Glass
**Created**: 2026-09-02T21:43:16.932+0000
**Updated**: 2026-09-28T16:35:39.591+0000
**URL**: https://jira.cs.sys/browse/CLM-505

**Labels**: ProServ_Ops, legal
**Components**: Ironclad, Salesforce

## Description

*As a* legal owner using the system
*I want* contract record updates to properly sync between our system and the Ironclad repository
*So that* I can rely on accurate, real-time contract status information for decision making
h2. Acceptance Criteria
 # *Given* a contract status is updated in Ironclad
*When* the system receives the update notification/webhook
*Then* the contract record in our system should reflect the new status 

 # *Given* I view a contract record in our system
*When* I check the same contract in Ironclad
*Then* all key fields (status, dates, parties, etc.) should match exactly

h2. Definition of Done
 * [ ] Sync mechanism handles all contract field updates reliably

h2. Questions for Clarification
 * Which specific fields besides status are affected?
 * What's the expected sync frequency/timing?
 * Are there any error logs showing the root cause?

h2. Solution Notes

*Components*

  1. legl_IcContractStatusQueueable
  - Type: Queueable (extends QueueableBase)
  - Purpose: Performs the actual reconciliation work with API callout capability
  - Key Features:
    - Queries Ironclad API for recently updated contracts
    - Compares Ironclad data against Salesforce records
    - Syncs only contracts with actual discrepancies (Status or Renewal_Type)
    - Comprehensive error handling with exception logging

  2. legl_IcContractStatusSchedulable
  - Type: Schedulable wrapper
  - Purpose: Enables scheduled execution of the queueable
  - Key Features:
    - Enqueues the queueable job via QueueableManager
    - Configurable lookback period
    - Follows CrowdStrike's asynchronous processing standards

  *Technical Implementation*

  *Execution Flow*

  1. Scheduled Job Triggers
     ↓
  2. legl_IcContractStatusSchedulable.execute()
     ↓
  3. Enqueues legl_IcContractStatusQueueable via QueueableManager
     ↓
  4. Queueable executes:
     a. Call Ironclad API (GET /public/api/v1/records?lastUpdated=\{timestamp})
     b. Query matching Salesforce contracts
     c. Filter to contracts with Status or Renewal Type discrepancies
     d. Call legl_IroncladContractsService.syncStatus()
     e. Commit Unit of Work
     ↓
  5. Exception handling and logging if needed

  *Key Methods*

  legl_IcContractStatusQueueable.execute() (line 31)
  - Orchestrates the entire reconciliation process
  - Early returns for efficiency (no data = no processing)
  - Try-catch around UoW commit with exception logging

  getRecentlyUpdatedContracts() (line 87)
  - Calls Ironclad API with lastUpdated filter
  - Default lookback: 25 hours (configurable)
  - Returns Map<String, Object> keyed by Ironclad contract ID
  - Logs API errors via ExceptionLogBuilder

  filterContractsWithStatusDiscrepancies() (line 191)
  - Compares two fields between systems:
    - contractStatus.status → Status__c
    - contractStatus.enhancedStatus → Renewal_Type__c
  - Only returns contracts with actual differences
  - Reduces unnecessary DML operations

  *Data Access Patterns*

  Selector Usage (line 174-181):
  contractSelector.setDataAccess(AccessLevel.SYSTEM_MODE);
  contractSelector.getWithoutSharing(...);
  - Uses SYSTEM_MODE for selector access
  - Ensures contracts are visible regardless of sharing rules

  Service Layer Integration (line 53-60):
  - Instantiates service via Application factory
  - Delegates status sync logic to legl_IroncladContractsService
  - Passes Unit of Work for transactional control

  *Configurable Lookback Period*

  Both classes support custom lookback windows:

  // Default: 25 hours
  new legl_IcContractStatusQueueable()
  new legl_IcContractStatusSchedulable()

  // Custom: 48 hours
  new legl_IcContractStatusQueueable(48)
  new legl_IcContractStatusSchedulable(48)

  Why 25 hours?
  - Daily job runs at 12 AM
  - 25-hour window provides 1-hour overlap
  - Accounts for clock drift and delayed job execution
  - Prevents missing contracts if job runs slightly late

  *Error Handling*

  Three-Tier Approach

  1. API Callout Errors (line 102-127)
    - Catches HTTP failures and non-200 responses
    - Logs with endpoint and request details
    - Returns empty map to gracefully fail
  2. DML Errors (line 66-78)
    - Try-catch around Unit of Work commit
    - Logs with process name and method context
    - Prevents job failure from blocking future runs
  3. Parse Errors (line 145-165)
    - Defensive null checks and type validation
    - Handles malformed JSON gracefully
    - Returns empty collections rather than throwing

  *Exception Logging Pattern*

  Exception_Log__c exceptionLog = new ExceptionLogBuilder()
    .setMethod('legl_IcContractStatusQueueable.execute')
    .setProcess('Ironclad Contract Status Sync')
    .setException(ex)
    .build();

  ((glbl_ExceptionLoggerService) glbl_Application.serviceFactory
    .newInstance(glbl_ExceptionLoggerService.class))
    .insertLog(exceptionLog);

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | eglass |
| `customfield_10003` | Story Points | 4.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@6e91766d[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6b73a108[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|hypevc:07c3n1wi" |
| `customfield_11700` | Time in Status | "3_*:*_1_*:*_0_*|*_10031_*:*_1_*:*_719022245" |
| `customfield_11701` | Date of First Response | "2026-09-11T16:28:02.789+0000" |
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
| `customfield_17641` | Last Comment | "[Jitesh Bhatia|https://gitlab.cs.sys/jitesh.bhatia] mentioned this issue in [a merge request|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/merge_requests/8568] of [CrowdStrike / GTM / SFDC / Commercial|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial] on branch [feature/US-0041361|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/tree/feature/US-0041361]:{quote}US-0041361 [CLM-505] - Syncing Updates from Ironclad to SF Contract Record{quote}" |
| `customfield_20217` | [CHART] Date of First Response | "2026-09-11T16:28:02.789+0000" |
| `customfield_20218` | [CHART] Time in Status | "3_*:*_1_*:*_0_*|*_10031_*:*_1_*:*_719022245" |
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
| `customfield_22604` | originId | "4330637" |
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
| `lastViewed` | Last Viewed | "2026-09-26T01:52:54.305+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Jitesh Bhatia - 2026-09-11T16:28:02.789+0000

CC: [~jbhatia] 
### Jitesh Bhatia - 2026-09-11T16:32:49.492+0000

One possibility might be to trigger the callout to retrieve the Status and update it in Salesforce whenever the Ironclad Contract record is updated. Currently only happens on insert and when the Webhook Status event fires.
### Jitesh Bhatia - 2026-09-11T16:35:01.735+0000

[~vchauhan02] to create Ironclad support ticket to see if they can expose the Standard Status property so we can use it in the Record Sync
### Jitesh Bhatia - 2026-09-11T16:35:54.504+0000

[~eglass] do you have some examples where this didn't sync over?
### Liz Glass - 2026-09-11T16:52:39.549+0000

[~jbhatia] I don't recall to be honest. This even happened to you though when you were making updates. You said that you had to push them a different way. I feel like this primarily happened on migrated records. 
### Jitesh Bhatia - 2026-09-11T22:13:38.780+0000

Support ticket created by Vikas - https://support.ironcladapp.com/hc/en-us/requests/113594
### Vikas Chauhan - 2026-09-15T05:18:12.990+0000

As per Ironclad, currently there's no OOTB capability to reveal the *Status* property directly or indirectly via UI using formula, or directly as an outbound mapping in the Record Sync. Ironclad has raised a feature request to make *'Status'* field available; however, there's no ETA provided.

Hence, until then, *we have to rely on custom code using the REST API* to retrieve the status on update, as we're currently handling it only via Webhook, which could be sometimes unavailable due to server downtime or any other reason, thus making it not reliable.

CC: [~jbhatia] ,[~eglass] 
### Jitesh Bhatia - 2026-09-23T02:45:18.243+0000

Copado story - https://crowdstrikecopado20232.lightning.force.com/lightning/r/copado__User_Story__c/a25VS000006ea1JYAQ/view
### svc_it_gitlab_jira - 2026-09-25T21:49:28.240+0000

[Jitesh Bhatia|https://gitlab.cs.sys/jitesh.bhatia] mentioned this issue in [a merge request|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/merge_requests/8568] of [CrowdStrike / GTM / SFDC / Commercial|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial] on branch [feature/US-0041361|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/tree/feature/US-0041361]:{quote}US-0041361 [CLM-505] - Syncing Updates from Ironclad to SF Contract Record{quote}
