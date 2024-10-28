@EndUserText.label: 'Payment Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZMW_C_PAY
  as projection on ZMW_I_Pay

{
  key Claim,
  key Subclaim,
  key Payment,
      Pampaid,
      CurrencyCode,
      Bentype,
      PayStat,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
      
      /* Associations */
      _Claim : redirected to ZMW_C_CLAIM,     
      _Subclaim : redirected to parent ZMW_C_SUBCLAIM,
      _Currency,
      _Paystat
}
