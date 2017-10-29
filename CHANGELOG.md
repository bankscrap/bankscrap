# Changelog

## 2.0.6

- Added `:description_detail` field to Bankscrap::Transaction to store secondary description for a transaction
provided by some banks.

## 2.0.5

- Added `:raw_data` field to Bankscrap::Account class to store all the raw data for an account retrieved by a bank API.

## 2.0.4

- [Fixed CLI coloring on banks with currencies](https://github.com/bankscrap/bankscrap/commit/07e23a2418e7e07e1f01824aac44b25f8778ca69) (Thanks to @zenitraM for this)
- [Added `operation_date` to transactions](https://github.com/bankscrap/bankscrap/commit/b35fe933036de1f0193ba1b2933d3d25768d1b7b)
