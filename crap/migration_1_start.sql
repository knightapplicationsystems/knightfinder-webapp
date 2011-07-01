DROP TABLE IF EXISTS my_venues;
CREATE TABLE my_venues (
  id integer primary key,
  Venue varchar NOT NULL,
  Address1 varchar NOT NULL,
  Address2 varchar character ucs2 NOT NULL,
  Address3 varchar default NULL,
  City varchar NOT NULL,
  County varchar default NULL,
  PostCode varchar NOT NULL,
  PrimaryPhone varchar NOT NULL,
  SecondaryPhone varchar default NULL,
  PrimaryEmail varchar default NULL,
  SecondaryEmail varchar default NULL,
  Homepage varchar default NULL,
  Latitude decimal NOT NULL,
  Longitude decimal NOT NULL,
  IsActive tinyintNOT NULL default '1'
);