include: "adset.view"
include: "fivetran_base.view"

explore: ad_fb_adapter {
  view_name: ad
  from: ad_fb_adapter
  hidden: yes

  join: adset {
    from: adset_fb_adapter
    type: left_outer
    sql_on: ${ad.adset_id} = ${adset.id} ;;
    relationship: many_to_one
  }

  join: campaign {
    from: campaign_fb_adapter
    type: left_outer
    sql_on: ${adset.campaign_id} = ${campaign.id} ;;
    relationship: many_to_one
  }
}

view: ad_fb_adapter {
  extends: [fivetran_base_fb_adapter, facebook_ads_config]
  derived_table: {
    sql:
    (
      SELECT ad_history.* FROM `{{ ad.facebook_ads_schema._sql }}.ad_history` as ad_history
      INNER JOIN (
        SELECT
        id, max(updated_time) as max_update_time
        FROM `{{ ad.facebook_ads_schema._sql }}.ad_history`
        GROUP BY id) max_ad_history
      ON max_ad_history.id = ad_history.id
      AND max_ad_history.max_update_time = ad_history.updated_time
    ) ;;
  }

  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
  }

  dimension: account_id {
    hidden: yes
    type: number
    sql: ${TABLE}.account_id ;;
  }

  dimension: adset_id {
    hidden: yes
    type: number
    sql: ${TABLE}.ad_set_id ;;
  }

  dimension: bid_amount {
    hidden: yes
    type: number
    sql: ${TABLE}.bid_amount ;;
  }

  dimension: bid_type {
    hidden: yes
    type: string
    sql: ${TABLE}.bid_type ;;
  }

  dimension: campaign_id {
    hidden: yes
    type: number
    sql: ${TABLE}.campaign_id ;;
  }

  dimension: configured_status {
    hidden: yes
    type: string
    sql: ${TABLE}.configured_status ;;
  }

  dimension_group: created {
    hidden: yes
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_time ;;
  }

  dimension: creative_id {
    hidden: yes
    type: number
    sql: ${TABLE}.creative_id ;;
  }

  dimension: effective_status {
    hidden: yes
    type: string
    sql: ${TABLE}.effective_status ;;
  }

  dimension: status_active {
    hidden: yes
    type: string
    sql: ${effective_status} = "ACTIVE" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: status {
    hidden: yes
    type: string
    sql: ${TABLE}.status ;;
  }
}
