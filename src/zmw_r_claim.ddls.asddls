@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Claim Entity'
//@Metadata.allowExtensions: true
define root view entity ZMW_R_CLAIM
  as select from zmw_claim as Claim

  composition [0..*] of ZMW_I_Subclaim as _Subclaim

  association [1..1] to ZMW_I_Status   as _Status  on $projection.Status = _Status.ClaimStatus
  association [1..1] to ZMW_I_POLPROD  as _PolProd on $projection.Polprod = _PolProd.Polprod
  association [1..1] to ZMW_I_CLTYPE   as _ClType  on $projection.Clmtype = _ClType.Clmtype

{
  key claim                 as Claim,
      polprod               as Polprod,
      clmtype               as Clmtype,
      status                as Status,

      case status
       when 'O' then 'Open'
       when 'C' then 'Closed'
       when 'N' then 'No Claim'
       else 'Open' 
       end                  as StatusText,

      case status
       when 'O' then 3
       when 'C' then 2
       when 'N' then 1
       else 3
       end                  as Criticality,

      policy                as Policy,
      lossdate              as Lossdate,
      opendate              as Opendate,
      claim_desc            as ClaimDesc,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      bookingfee            as BookingFee,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      totalprice            as TotalPrice,
      currencycode          as CurrencyCode,      
      
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
      _Subclaim,
      _Status,
      _PolProd,
      _ClType
}
