/* Data Virtuality exported objects */
/* Created: 06.12.22  00:30:52.943 */
/* Server version: 1.8.11-SNAPSHOT */
/* Build: 3083445 */
/* Build date: 2022-11-04 */
/* Exported by Studio ver.3.0.10 (rev.3d7455c). Build date is 2022-09-28. */
/* Please set statement separator to ;; before importing */

/* Enable maintenance mode */
EXEC SYSADMIN.setDefaultOptionValue("opt" => 'MAINTENANCE', "val" => 'true') OPTION $NOFAIL ;;





/* Exported virtual schemas */
EXEC SYSADMIN.createVirtualSchema("name" => 'odata') OPTION $NOFAIL ;;

EXEC SYSADMIN.createVirtualSchema("name" => 'facebook') OPTION $NOFAIL ;;

CREATE view facebook.dates_2022
as
select "date" from "facebook_DV.getDates"
where
    "start_date" = {d'2020-01-01'}
    and "end_date" = curdate()
    and dayofmonth("date") = 1 ;;

CREATE view facebook.level_values 
(
	level string (20)
)
as 
select 'campaign' level 
union all 
select 'adset' 
union all 
select 'ad'
union all 
select 'account' ;;

create view views.getTypeOfResource as
SELECT
    p."id"
    ,p."role"
    ,p."resource"
    ,case 
    	when '*' = p."resource" then 'WILDCARD'
    	when 'UNDEFINED' = gtor.getTypeOfResource then 
    		case
    			when sch.name is not null then 'SCHEMA'
    			else 'UNDEFINED'
    		end
    	else gtor.getTypeOfResource
    end as sysadmin_getTypeOfResource
    ,p."permission"
    ,p."condition"
    ,p."isConstraint"
    ,p."mask"
    ,p."maskOrder"
    ,p."creationDate"
    ,p."lastModifiedDate"
    ,p."creator"
    ,p."modifier"
    ,sch.name as schema_name
FROM
    "SYSADMIN.Permissions" p
    join ( 
    	select
    		id
    		,(select type from (call sysadmin.getTypeOfResource(trim("resource"))) x) as getTypeOfResource
    	from
    		"SYSADMIN.Permissions"
    ) gtor
    	on p.id = gtor.id
  	left join "SYS.Schemas" sch
  		on lower(p.resource) = lower(sch.name) ;;

CREATE procedure views.create_wrapper
(
		schemaname_source string not null,
		procedurename_source string not null,
		schemaname_target string not null,
		procedurename_target string	not null	
) 
returns (statement clob)
as
begin
	execute immediate
	'select 
		E''create procedure '|| schemaname_target || '.' || procedurename_target || '\n(\n'' 
		|| string_agg(name || '' '' || case when datatype  = ''string'' then datatype || ''(256)'' else datatype end, E'',\n'') filter (where type = ''In'')
		|| E''\n) ''
		|| E''\nRETURNS \n(\n''
		|| string_agg
			(
				case when exists(select 1 from "SYS.ProcedureParams" a where SchemaName = ''' || schemaname_target || ''' and ProcedureName = ''' || procedurename_source || ''' and a.name = b.name and type = ''In'') then name || ''_out'' else name end 
				|| '' '' 
				|| case when datatype  = ''string'' then datatype || ''(256)'' else datatype end, E'',\n''
			) filter (where type != ''In'')
		|| E''\n) \nAS \nBEGIN \nCALL "' || schemaname_source || '"."' || procedurename_source || '"(\n''
		|| string_agg(name || ''=> '' || name, E'',\n'') filter (where type = ''In'')
		|| E''\n); \nend;'' 
	from "SYS.ProcedureParams" b
	where SchemaName = ''' || schemaname_source || ''' and ProcedureName = ''' || procedurename_source  || '''';
end ;;

create procedure facebook.test1
(
account_id long,
campaign_id long,
start_date date,
end_date date,
batchSize integer,
level string(256),
daily boolean,
clean28days boolean,
breakdown_age boolean,
breakdown_country boolean,
breakdown_device_platform boolean,
breakdown_gender boolean,
breakdown_publisher_platform boolean,
actionsOnly boolean,
action_attributes_mask string(256),
syncMode boolean,
fieldsOverride string(256),
no_ads_action_stats boolean,
customFields string(256),
target_table string(256),
preview boolean
) 
RETURNS 
(
account_id_out long,
account_name string(256),
campaign_id_out long,
campaign_name string(256),
adset_id long,
adset_name string(256),
ad_id long,
ad_name string(256),
date_start date,
date_stop date,
impressions integer,
clicks integer,
reach integer,
spend bigdecimal,
cpc bigdecimal,
cpm bigdecimal,
cpp bigdecimal,
ctr bigdecimal,
frequency bigdecimal,
age string(256),
country string(256),
device_platform string(256),
gender string(256),
publisher_platform string(256),
account_currency string(256),
buying_type string(256),
canvas_avg_view_percent bigdecimal,
canvas_avg_view_time bigdecimal,
conversion_rate_ranking string(256),
cost_per_estimated_ad_recallers bigdecimal,
cost_per_inline_link_click bigdecimal,
cost_per_inline_post_engagement bigdecimal,
cost_per_unique_click bigdecimal,
cost_per_unique_inline_link_click bigdecimal,
engagement_rate_ranking string(256),
estimated_ad_recall_rate bigdecimal,
estimated_ad_recallers integer,
full_view_impressions integer,
full_view_reach integer,
inline_link_click_ctr bigdecimal,
inline_link_clicks integer,
inline_post_engagement integer,
objective string(256),
quality_ranking string(256),
social_spend bigdecimal,
unique_clicks integer,
unique_ctr bigdecimal,
unique_inline_link_click_ctr bigdecimal,
unique_inline_link_clicks integer,
unique_link_clicks_ctr bigdecimal,
video_play_curve_actions clob,
ads_action_stats xml
) 
AS 
BEGIN 
CALL "facebook_DV"."MarketingInsights"(
account_id=> account_id,
campaign_id=> campaign_id,
start_date=> start_date,
end_date=> end_date,
batchSize=> batchSize,
level=> level,
daily=> daily,
clean28days=> clean28days,
breakdown_age=> breakdown_age,
breakdown_country=> breakdown_country,
breakdown_device_platform=> breakdown_device_platform,
breakdown_gender=> breakdown_gender,
breakdown_publisher_platform=> breakdown_publisher_platform,
actionsOnly=> actionsOnly,
action_attributes_mask=> action_attributes_mask,
syncMode=> syncMode,
fieldsOverride=> fieldsOverride,
no_ads_action_stats=> no_ads_action_stats,
customFields=> customFields,
target_table=> target_table,
preview=> preview
); 
end ;;

create procedure views.create_wrapper_view
(
        schemaname_source string,
        procedurename_source string,
        schemaname_target string,
        viewname_target string      
) 
returns (statement clob)
as
begin
    execute immediate
    'select 
        E''create view '|| schemaname_target || '.' || viewname_target || E'\n(\n'' 
        || string_agg(name || '' '' || case when datatype  = ''string'' then datatype || ''(256)'' else datatype end, E'',\n'') 
        || E''\n)\n ''
        || E''AS \nselect '' || string_agg(name, E'',\n'') || E''\nfrom  "' || schemaname_source || '"."' || procedurename_source || '"''
    from "SYS.ProcedureParams" b
    where SchemaName = ''' || schemaname_source || ''' and ProcedureName = ''' || procedurename_source  || '''';
end ;;

/* Data Virtuality exported objects */
/* Created: 15.11.22  00:08:33.285 */
/* Server version: 3.0.10 */
/* Build: 5d4843a */
/* Build date: 2022-09-28 */
/* Exported by Studio ver.3.0.10 (rev.3d7455c). Build date is 2022-09-28. */
/* Please set statement separator to ;; before importing */

/* Enable maintenance mode */



create view odata.MySql_cloud_salesorderdetail(
    "salesorderid" bigdecimal
    ,"linenumber" integer
    ,"productid" integer
    ,"specialofferid" integer
    ,"carriertrackingnumber" string
    ,"orderqty" integer
    ,"unitprice"bigdecimal
    ,"unitpricediscount" double
    ,"modifieddate" timestamp
    ,"rowguid" string
    ,"linetotal" double
    ,primary key (salesorderid)
) as
SELECT
    "salesorderid"
    ,"linenumber"
    ,"productid"
    ,"specialofferid"
    ,"carriertrackingnumber"
    ,"orderqty"
    ,"unitprice"
    ,"unitpricediscount"
    ,"modifieddate"
    ,"rowguid"
    ,"linetotal"
FROM
    "MySql_cloud.salesorderdetail" LIMIT 500 ;;

CREATE view views.salesperson as
SELECT "salespersonid", "territoryid", "salesquota", "bonus", "rowguid", "commissionpct", "salesytd", "saleslastyear", "modifieddate" FROM "MySql_cloud.salesperson" ;;

CREATE view views.salesorderdetail as
SELECT "salesorderid", "linenumber", "productid", "specialofferid", "carriertrackingnumber", "orderqty", "unitprice", "unitpricediscount", "modifieddate", "rowguid", "linetotal" FROM "MySql_cloud.salesorderdetailregular" ;;

CREATE view views.salesorderheader as
SELECT "salesorderid", "customerid", "salespersonid", "territoryid", "purchaseordernumber", "currencycode", "subtotal", "taxamt", "freight", "orderdate", "revisionnumber", "status", "billtoaddressid", "shiptoaddressid", "shipdate", "shipmethodid", "creditcardid", "creditcardnumber", "creditcardexpmonth", "creditcardexpyear", "contactid", "onlineorderflag", "comment", "modifieddate", "rowguid", "duedate", "salesordernumber", "totaldue" FROM "MySql_cloud.salesorderheader" ;;

CREATE view "odata"."getTypeOfResource"(
	"id" biginteger
	,"role" string
	,"resource" string
	,"sysadmin_getTypeOfResource" string
	,"permission" string
	,"condition" string
	,"isConstraint" boolean
	,"mask" string
	,"maskOrder" integer
	,"creationDate" timestamp
	,"lastModifiedDate" timestamp
	,"creator" string
	,"modifier" string
	,"schema_name" string
	,primary key("id")
) as 
SELECT
    p."id"
    ,p."role"
    ,p."resource"
    ,case 
    	when '*' = p."resource" then 'WILDCARD'
    	when 'UNDEFINED' = gtor.getTypeOfResource then 
    		case
    			when sch.name is not null then 'SCHEMA'
    			else 'UNDEFINED'
    		end
    	else gtor.getTypeOfResource
    end as sysadmin_getTypeOfResource
    ,p."permission"
    ,p."condition"
    ,p."isConstraint"
    ,p."mask"
    ,p."maskOrder"
    ,p."creationDate"
    ,p."lastModifiedDate"
    ,p."creator"
    ,p."modifier"
    ,sch.name as schema_name
FROM
    "SYSADMIN.Permissions" p
    join ( 
    	select
    		id
    		,(select type from (call sysadmin.getTypeOfResource(trim("resource"))) x) as getTypeOfResource
    	from
    		"SYSADMIN.Permissions"
    ) gtor
    	on p.id = gtor.id
  	left join "SYS.Schemas" sch
  		on lower(p.resource) = lower(sch.name) ;;

CREATE view "odata"."salesorderdetail"(
	"salesorderid" integer
	,"linenumber" integer
	,"productid" integer
	,"specialofferid" integer
	,"carriertrackingnumber" string
	,"orderqty" integer
	,"unitprice" bigdecimal
	,"unitpricediscount" double
	,"modifieddate" timestamp
	,"rowguid" string
	,"linetotal" double
	,primary key("salesorderid")
) as 
SELECT "salesorderid", "linenumber", "productid", "specialofferid", "carriertrackingnumber", "orderqty", "unitprice", "unitpricediscount", "modifieddate", "rowguid", "linetotal" FROM "MySql_cloud.salesorderdetailregular" ;;

CREATE view "odata"."salesorderheader"(
	"salesorderid" integer
	,"customerid" integer
	,"salespersonid" integer
	,"territoryid" integer
	,"purchaseordernumber" string
	,"currencycode" string
	,"subtotal" bigdecimal
	,"taxamt" bigdecimal
	,"freight" bigdecimal
	,"orderdate" timestamp
	,"revisionnumber" integer
	,"status" integer
	,"billtoaddressid" integer
	,"shiptoaddressid" integer
	,"shipdate" timestamp
	,"shipmethodid" integer
	,"creditcardid" integer
	,"creditcardnumber" string
	,"creditcardexpmonth" integer
	,"creditcardexpyear" integer
	,"contactid" integer
	,"onlineorderflag" integer
	,"comment" string
	,"modifieddate" timestamp
	,"rowguid" string
	,"duedate" timestamp
	,"salesordernumber" string
	,"totaldue" bigdecimal
	,primary key("salesorderid")
) as 
SELECT "salesorderid", "customerid", "salespersonid", "territoryid", "purchaseordernumber", "currencycode", "subtotal", "taxamt", "freight", "orderdate", "revisionnumber", "status", "billtoaddressid", "shiptoaddressid", "shipdate", "shipmethodid", "creditcardid", "creditcardnumber", "creditcardexpmonth", "creditcardexpyear", "contactid", "onlineorderflag", "comment", "modifieddate", "rowguid", "duedate", "salesordernumber", "totaldue" FROM "MySql_cloud.salesorderheader" ;;

CREATE view "odata"."salestaxrate"(
	"salestaxrateid" integer
	,"stateprovinceid" integer
	,"countryregioncode" string
	,"taxtype" integer
	,"taxrate" double
	,"name" string
	,"modifieddate" timestamp
	,primary key("salestaxrateid")
) as 
SELECT "salestaxrateid", "stateprovinceid", "countryregioncode", "taxtype", "taxrate", "name", "modifieddate" FROM "MySql_cloud_fullpath.dv_learn_mysql.salestaxrate" LIMIT 500 ;;

CREATE procedure views.make_view_odata_compatible(
	src_table_schema string not null,
	src_table_name string not null,
	targ_table_schema string not null,
	targ_table_name string not null
) 
returns(
	old_view_def string not null,
	new_view_def string not null,
	is_inplace_alter boolean not null
) as
begin
	declare boolean is_inplace_alter = false;
	
	-- inline modification is not supported. It's too risky.
	if (src_table_schema = targ_table_schema and src_table_name = targ_table_name)
	begin
		error 'Inline modifications are not supported for safety reasons.'; -- comment out this line if you want inline replacement
		is_inplace_alter = true;
	end
	
	declare string TAB = char(9);
	declare string CRLF = char(13) || char(10);
	declare string LF = char(10);
	declare string old_view_def = (SELECT "view_definition" FROM "INFORMATION_SCHEMA.views" where table_schema = src_table_schema and table_name = src_table_name);
	declare string explicit_result_schema_line_template = '<<TAB>><<COMMA>>"<<col_name>>" <<type>><<NOT_NULL>><<NEWLINE>>';
	declare string explicit_result_schema = '';
	declare string explicit_result_schema_template = '"<<schema_name>>"."<<view_name>>"(<<NEWLINE>><<explicit_result_schema>><<NEWLINE>>)';
	declare string primary_key;
	declare string primary_key_template = '<<TAB>>,primary key("<<col_name>>")<<NEWLINE>>';

	loop on (SELECT
		    "table_schema"
		    ,"table_name"
		    ,"column_name"
		    ,"ordinal_position"
		    ,"is_nullable"
		    ,"udt_name"
		FROM
		    "INFORMATION_SCHEMA.columns"
		where
			table_schema = src_table_schema and
			table_name = src_table_name
		order by
			ordinal_position) as cur
	begin
		declare string comma = case when cur.ordinal_position = 1 then '' else ',' end;
		declare string nullable = case when cur.is_nullable = 'YES' then '' else ' NOT NULL ' end;
		
		explicit_result_schema = explicit_result_schema || replace(replace(replace(replace(replace(replace(explicit_result_schema_line_template,
			'<<TAB>>', TAB),
			'<<COMMA>>', comma),
			'<<col_name>>', cur.column_name),
			'<<type>>', cur.udt_name),
			'<<NOT_NULL>>', nullable),
			'<<NEWLINE>>', CRLF);		

		if (cur.ordinal_position = 1)
		begin
			primary_key = replace(replace(replace(primary_key_template,
				'<<TAB>>', TAB),
				'<<col_name>>', cur.column_name),
				'<<NEWLINE>>', CRLF);
		end
	end
	
	declare string create_or_alter = case is_inplace_alter when true then 'ALTER' else 'CREATE' end;
	
	-- the regex was tested with https://regex101.com/
	-- \bcreate\s+view\s+"{0,1}\bviews\b"{0,1}\s*\.\s*"{0,1}\bgetTypeOfResource\b"{0,1}\s+as\b
	declare string new_view_def = REGEXP_REPLACE(old_view_def, 
		'\bcreate\s+view\s+"{0,1}\b' || src_table_schema || '\b"{0,1}\s*\.\s*"{0,1}\b' || src_table_name || '\b"{0,1}\s+as\b',
		create_or_alter || ' view "' || targ_table_schema || '"."' || targ_table_name || '"(' || CRLF || explicit_result_schema || primary_key || ') as ',
		'im');
				
	select old_view_def, new_view_def, is_inplace_alter;
end ;;

CREATE view "odata"."salesperson"(
	"salespersonid" integer
	,"territoryid" integer
	,"salesquota" bigdecimal
	,"bonus" bigdecimal
	,"rowguid" string
	,"commissionpct" double
	,"salesytd" bigdecimal
	,"saleslastyear" bigdecimal
	,"modifieddate" timestamp
	,primary key("territoryid")
) as 
SELECT "salespersonid", "territoryid", "salesquota", "bonus", "rowguid", "commissionpct", "salesytd", "saleslastyear", "modifieddate" FROM "MySql_cloud.salesperson" ;;

CREATE procedure views.hash_str(str string(512) default 'foo')
returns(hashed string not null) as
begin
	select 'hash: ' || hashcode(str);
end ;;

CREATE procedure "facebook.MarketingInsights"
(
	account_id long default '641107513751' Options (Annotation 'Ad Account ID'),
	campaign_id long Options (Annotation 'Ad Campaign ID (overrides Account ID)'),
	start_date date Options (Annotation 'Start Date'),
	end_date date Options (Annotation 'End Date'),
	batchSize integer Options (Annotation 'Download data in batches, duration in days'),
	"level" string default 'campaign' Options (Annotation 'Level: Campaign, Adset or Ad'),
	daily boolean default 'false' Options (Annotation 'Daily precision or summary data'),
	clean28days boolean Options (Annotation 'Remove 28 last days each time'),
	breakdown_age boolean Options (Annotation 'Breakdown results by country'),
	breakdown_country boolean Options (Annotation 'Breakdown results by country'),
	breakdown_device_platform boolean Options (Annotation 'Breakdown results by country'),
	breakdown_gender boolean Options (Annotation 'Breakdown results by country'),
	breakdown_publisher_platform boolean Options (Annotation 'Breakdown results by country'),
	actionsOnly boolean Options (Annotation 'Only request actions, otherwise all ads action stats'),
	action_attributes_mask string Options (Annotation 'Override mask 101010 for 1d_click,1d_view,7d_click,7d_view,28d_click,28d_view'),
	syncMode boolean Options (Annotation 'If true, data is requested synchronously'),
	fieldsOverride string Options (Annotation 'Requests only the specified list of fields from the API'),
	no_ads_action_stats boolean Options (Annotation 'Do not request ad action stats, and only create the single table'),
	customFields string Options (Annotation 'JSON object to define extra columns'),
	target_table string Options (Annotation 'Table name to save the data to'),
	preview boolean Options (Annotation 'Preview only, don''t write into table')
) Returns (
	account_id_out long,
	account_name string,
	campaign_id_out long,
	campaign_name string,
	adset_id long,
	adset_name string,
	ad_id long,
	ad_name string,
	start_date_out date,
	stop_date date,
	impressions integer,
	clicks integer,
	reach integer,
	spend decimal,
	cpc decimal,
	cpm decimal,
	cpp decimal,
	ctr decimal,
	frequency decimal,
	age string,
	country string,
	device_platform string,
	gender string,
	publisher_platform string,
	account_currency string,
	buying_type string,
	canvas_avg_view_percent decimal,
	canvas_avg_view_time decimal,
	conversion_rate_ranking string,
	cost_per_estimated_ad_recallers decimal,
	cost_per_inline_link_click decimal,
	cost_per_inline_post_engagement decimal,
	cost_per_unique_click decimal,
	cost_per_unique_inline_link_click decimal,
	engagement_rate_ranking string,
	estimated_ad_recall_rate decimal,
	estimated_ad_recallers integer,
	full_view_impressions integer,
	full_view_reach integer,	
	inline_link_click_ctr decimal,
	inline_link_clicks integer,
	inline_post_engagement integer,
	objective string,
	quality_ranking string,
	social_spend decimal,
	unique_clicks integer,
	unique_ctr decimal,
	unique_inline_link_click_ctr decimal,
	unique_inline_link_clicks integer,
	unique_link_clicks_ctr decimal,
	video_play_curve_actions clob,
	ads_action_stats xml
) Options (Annotation 'Marketing Insights Wrapper for relational relational syntax') 
as
begin
	call "facebook_DV.MarketingInsights"
	(
		"account_id" => account_id,
		"campaign_id" => campaign_id,
		"start_date" => start_date,
		"end_date" => end_date,
		"batchSize" => batchSize,
		"level" => level,
		"daily" => daily,
		"clean28days" => clean28days,
		"breakdown_age" => breakdown_age,
		"breakdown_country" => breakdown_country,
		"breakdown_device_platform" => breakdown_device_platform,
		"breakdown_gender" => breakdown_gender,
		"breakdown_publisher_platform" => breakdown_publisher_platform,
		"actionsOnly" => actionsOnly,
		"action_attributes_mask" => action_attributes_mask,
		"syncMode" => syncMode,
		"fieldsOverride" => fieldsOverride,
		"no_ads_action_stats" => no_ads_action_stats,
		"customFields" => customFields,
		"target_table" => target_table,
		"preview" => preview
	);
end ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights', "remark" => 'Marketing Insights Wrapper for relational relational syntax') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.account_id', "remark" => 'Ad Account ID') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.campaign_id', "remark" => 'Ad Campaign ID (overrides Account ID)') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.start_date', "remark" => 'Start Date') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.end_date', "remark" => 'End Date') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.batchSize', "remark" => 'Download data in batches, duration in days') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.level', "remark" => 'Level: Campaign, Adset or Ad') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.daily', "remark" => 'Daily precision or summary data') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.clean28days', "remark" => 'Remove 28 last days each time') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.breakdown_age', "remark" => 'Breakdown results by country') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.breakdown_country', "remark" => 'Breakdown results by country') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.breakdown_device_platform', "remark" => 'Breakdown results by country') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.breakdown_gender', "remark" => 'Breakdown results by country') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.breakdown_publisher_platform', "remark" => 'Breakdown results by country') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.actionsOnly', "remark" => 'Only request actions, otherwise all ads action stats') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.action_attributes_mask', "remark" => 'Override mask 101010 for 1d_click,1d_view,7d_click,7d_view,28d_click,28d_view') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.syncMode', "remark" => 'If true, data is requested synchronously') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.fieldsOverride', "remark" => 'Requests only the specified list of fields from the API') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.no_ads_action_stats', "remark" => 'Do not request ad action stats, and only create the single table') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.customFields', "remark" => 'JSON object to define extra columns') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.target_table', "remark" => 'Table name to save the data to') OPTION $NOFAIL ;;
EXEC SYSADMIN.setRemark("name" => 'facebook.MarketingInsights.preview', "remark" => 'Preview only, don''t write into table') OPTION $NOFAIL ;;

CREATE view "facebook.MarketingInsights_v" 
(
	account_id_out long,
	account_name string(256),
	campaign_id_out long,
	campaign_name string(256),
	adset_id long,
	adset_name string(256),
	ad_id long,
	ad_name string(256),
	start_date_out date,
	stop_date date,
	impressions integer,
	clicks integer,
	reach integer,
	spend decimal,
	cpc decimal,
	cpm decimal,
	cpp decimal,
	ctr decimal,
	frequency decimal,
	age string(256),
	country string(256),
	device_platform string(256),
	gender string(256),
	publisher_platform string(256),
	account_currency string(256),
	buying_type string(256),
	canvas_avg_view_percent decimal,
	canvas_avg_view_time decimal,
	conversion_rate_ranking string(256),
	cost_per_estimated_ad_recallers decimal,
	cost_per_inline_link_click decimal,
	cost_per_inline_post_engagement decimal,
	cost_per_unique_click decimal,
	cost_per_unique_inline_link_click decimal,
	engagement_rate_ranking string(256),
	estimated_ad_recall_rate decimal,
	estimated_ad_recallers integer,
	full_view_impressions integer,
	full_view_reach integer,	
	inline_link_click_ctr decimal,
	inline_link_clicks integer,
	inline_post_engagement integer,
	objective string(256),
	quality_ranking string(256),
	social_spend decimal,
	unique_clicks integer,
	unique_ctr decimal,
	unique_inline_link_click_ctr decimal,
	unique_inline_link_clicks integer,
	unique_link_clicks_ctr decimal,
	video_play_curve_actions clob,
	ads_action_stats xml,
	account_id long,
	campaign_id long,
	start_date date,
	end_date date,
	batchSize integer,
	"level" string(256),
	daily boolean,
	clean28days boolean,
	breakdown_age boolean,
	breakdown_country boolean,
	breakdown_device_platform boolean,
	breakdown_gender boolean,
	breakdown_publisher_platform boolean,
	actionsOnly boolean,
	action_attributes_mask string(256),
	syncMode boolean,
	fieldsOverride string(256),
	no_ads_action_stats boolean,
	customFields string(256),
	target_table string(256),
	preview boolean
)
as 
select * from "facebook.MarketingInsights" ;;

--select * from (call views.make_view_odata_compatible('views', 'salesperson', 'odata', 'salesperson')) x;;


CREATE procedure views.make_schema_odata_compatible(	
	src_table_schema string not null,
	targ_table_schema string not null
) as
begin

loop on (SELECT "table_schema", "table_name" FROM "INFORMATION_SCHEMA.views" where table_schema = src_table_schema) as curView
begin
	loop on (select * from (call views.make_view_odata_compatible(
		"src_table_schema" => curView.table_schema,
		"src_table_name" => curView.table_name,
		"targ_table_schema" => targ_table_schema,
		"targ_table_name" => curView.table_name
		)) x) as cur
	begin
		if (cur.is_inplace_alter = False)
		begin			
			declare string drop_sql = 'drop view if exists "' || targ_table_schema || '"."' || curView.table_name || '";;';
			exec (drop_sql) without return;
		end
		
		exec (cur.new_view_def) without return;
	end	
end	
end ;;

CREATE view views.hash_str_v
(
str string(512),
hashed string
)
 AS 
select str,
hashed
from  "views"."hash_str" ;;

create procedure views.demo_proc_rel_command() as 
begin
declare string param = 'foodf';

select * from views.hash_str_v where str= param
union all
select param, hashed from (call "views.hash_str"("str" => param)) as a;

end ;;









/* Disable maintenance mode */
EXEC SYSADMIN.setDefaultOptionValue("opt" => 'MAINTENANCE', "val" => 'false') OPTION $NOFAIL ;;

