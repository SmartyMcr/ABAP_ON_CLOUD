@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Subclaim2 Root View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMW_I_Subclaim2 as select from zmw_subclaim as Subclaim2
  association to parent ZR_MW_CLAIM2 as _Claim2  on $projection.Claim = _Claim2.Claim
//  composition [0..*] of ZMW_I_PAY2   as _Pay2
  association [1..1] to ZMW_I_Status as _Status on $projection.Status = _Status.ClaimStatus

{
  key claim                 as Claim,
  key subclaim              as Subclaim,
      subcltype             as Subcltype,
      status                as Status,
      coverage              as Coverage,
      opendate              as Opendate,
      complexity            as Complexity,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      tot_paid              as TotalPaid,
      currency_code         as CurrencyCode,      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      /* Associations */
      _Claim2,
      _Status
//      _Pay2
     }
