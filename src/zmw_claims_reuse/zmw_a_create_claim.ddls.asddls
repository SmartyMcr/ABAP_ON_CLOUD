@EndUserText.label: 'Parameter for Creating a Claim'
define abstract entity ZMW_A_CREATE_CLAIM
{


  @Consumption.valueHelpDefinition: [ {
    entity    : {
      name    : 'ZMW_I_POLPROD',
      element : 'Polprod'
    }
  } ]
  polprod : zmw_polprod;

  @Consumption.valueHelpDefinition: [ {
    entity    : {
      name    : 'ZMW_I_CLTYPE',
      element : 'Clmtype'
    }
  } ]
  Clmtype     : zmw_cltype;

  //  @Consumption.valueHelpDefinition: [ {
  //    entity      : {
  //      name      : '/DMO/I_Flight_StdVH',
  //      element   : 'AirlineID'
  //    },
  //    additionalBinding: [ {
  //      localElement: 'flight_date',
  //      element   : 'FlightDate',
  //      usage     : #RESULT
  //    }, {
  //      localElement: 'connection_id',
  //      element   : 'ConnectionID',
  //      usage     : #RESULT
  //    } ]
  //  } ]


  //  carrier_id    : /dmo/carrier_id;
  //  @Consumption.valueHelpDefinition: [ {
  //    entity      : {
  //      name      : '/DMO/I_Flight_StdVH',
  //      element   : 'AirlineID'
  //    },
  //    additionalBinding: [ {
  //      localElement: 'flight_date',
  //      element   : 'FlightDate',
  //      usage     : #RESULT
  //    }, {
  //      localElement: 'carrier_id',
  //      element   : 'AirlineID',
  //      usage     : #FILTER_AND_RESULT
  //    } ]
  //  } ]
  //  connection_id : /dmo/connection_id;
  //  @Consumption.valueHelpDefinition: [ {
  //    entity      : {
  //      name      : '/DMO/I_Flight_StdVH',
  //      element   : 'AirlineID'
  //    },
  //    additionalBinding: [ {
  //      localElement: 'carrier_id',
  //      element   : 'AirlineID',
  //      usage     : #FILTER_AND_RESULT
  //    }, {
  //      localElement: 'connection_id',
  //      element   : 'ConnectionID',
  //      usage     : #FILTER_AND_RESULT
  //    } ]
  //  } ]
  //  flight_date   : /dmo/flight_date;

}
