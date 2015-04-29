#!/usr/bin/env ruby

require_relative 'sql_script'
require_relative 'sql_row_type'
require_relative 'sql_row'

    s = SqlScript.new(:postgresql)
    row_type = SqlRowType.new('tblCustomerInvoices',
                :TransactionType_0 => :string,
                :SiteCode_0        => :string,
                :GLCode_0          => :string,
                :Dimension1_0      => :string,
                :Dimension2_0      => :string,
                :Dimension3_0      => :string,
                :Dimension4_0      => :string,
                :ApplyToDocument_0 => :string,
                :Period_0          => :integer,
                :TransactionDate_0 => :date,
                :LedgerCode_0      => :string,
                :CustomerNumber_0  => :string,
                :DocumentNumber_0  => :string,
                :Description_0     => :string,
                :Amount_0          => :numeric,
                :TaxType_0         => :string,
                :TaxAmount_0       => :numeric,
                :ProjectsCode_0    => :string,
                :RevenueAccount_0  => :string,
                :ExchangeRate_0    => :numeric,
                :BankExchange_0    => :numeric,
                :HomeAmount_0      => :numeric,
                :AccountingDate_0  => :date,
                :Currency_0        => :string,
                :TermsCode_0       => :string,
                :DueDateBasis_0    => :date)

    row = SqlRow.new(row_type)
    row.set_value(:TransactionType_0 , 'C-INV')
    row.set_value(:SiteCode_0        , 'UF')
    row.set_value(:GLCode_0          , 'MAF')
    row.set_value(:Dimension1_0      , '2015_013 MOL CALEDON')
    row.set_value(:Dimension2_0      , 'RUBY')
    row.set_value(:Dimension3_0      , 'DUN-SW')
    row.set_value(:Period_0          , 4)
    row.set_value(:TransactionDate_0 , Date.today)
    row.set_value(:LedgerCode_0      , 'D')
    row.set_value(:CustomerNumber_0  , 'MAF')
    row.set_value(:DocumentNumber_0  , 'SWI000021')
    row.set_value(:Description_0     , 'SWI000021')
    row.set_value(:Amount_0          , 123.45)
    row.set_value(:TaxType_0         , '02')
    row.set_value(:TaxAmount_0       , 0)
    row.set_value(:ProjectsCode_0    , '1230909')
    row.set_value(:RevenueAccount_0  , '1-10-1')
    row.set_value(:ExchangeRate_0    , 14.1234)
    row.set_value(:BankExchange_0    , 1.0)
    row.set_value(:HomeAmount_0      , 1743.53)
    row.set_value(:AccountingDate_0  , Date.today)
    row.set_value(:Currency_0        , 'USD')
    row.set_value(:TermsCode_0       , 'X')
    row.set_value(:DueDateBasis_0    , Date.today)
    s.rows << row

    puts s.to_script

