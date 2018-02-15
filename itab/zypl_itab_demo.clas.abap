class ZYPL_ITAB_DEMO definition
  public
  final
  create public .

public section.

  methods GROUPBY .
  methods REDUCE .
  methods REDUCE_OLD .
  methods CONSTRUCTOR
    importing
      !IV_TABLE_NAME type TABNAME .
  methods LINE_ACCESS .
  methods LINE_ACCESS_OLD .
  methods READ .
  methods READ_OLD .
  methods FILTER .
  methods FILTER_OLD .
  methods CORRESPONDING .
  methods CORRESPONDING_OLD .
protected section.

  data:
    mt_orderadm_h TYPE SORTED TABLE OF crmd_orderadm_h WITH UNIQUE KEY guid.
  data:
    mt_proc_type TYPE TABLE OF crmc_proc_type .

  methods IS_COUNTABLE
    importing
      !IV_CREATED_BY type CRMD_ORDERADM_H-CREATED_BY
    returning
      value(RV_COUNTER) type INT4 .
private section.
ENDCLASS.



CLASS ZYPL_ITAB_DEMO IMPLEMENTATION.


  METHOD constructor.
    CASE iv_table_name.
      WHEN 'CRMD_ORDERADM_H'.
        SELECT * FROM crmd_orderadm_h INTO TABLE mt_orderadm_h.
      WHEN 'CRMC_PROC_TYPE'.
        SELECT * FROM crmc_proc_type INTO TABLE mt_proc_type.
    ENDCASE.
  ENDMETHOD.


  METHOD corresponding.
    TYPES:
      BEGIN OF struc_less_fields,
        client TYPE crmd_orderadm_h-client,
        type   TYPE crmd_orderadm_h-process_type,
        id     TYPE crmd_orderadm_h-object_id,
      END OF struc_less_fields.
    DATA: lt_less TYPE TABLE OF struc_less_fields.


    "Target                    Source                 Target  Source
    lt_less = CORRESPONDING #( mt_orderadm_h MAPPING  id    = object_id
                                                      type  = process_type
    "                                        Field exists in both but must not transfered
                                             EXCEPT   client ).


    TYPES:
      BEGIN OF struc_less_fields2,
        client       TYPE crmd_orderadm_h-client,
        object_id    TYPE crmd_orderadm_h-object_id,
        process_type TYPE crmd_orderadm_h-process_type,
      END OF struc_less_fields2.
    DATA: lt_less2 TYPE TABLE OF struc_less_fields2.

    MOVE-CORRESPONDING mt_orderadm_h TO lt_less2.

  ENDMETHOD.


  METHOD corresponding_old.
    TYPES:
      BEGIN OF struc_less_fields,
        client TYPE crmd_orderadm_h-client,
        type   TYPE crmd_orderadm_h-process_type,
        id     TYPE crmd_orderadm_h-object_id,
      END OF struc_less_fields.
    DATA: lt_less TYPE TABLE OF struc_less_fields.

    LOOP AT mt_orderadm_h ASSIGNING FIELD-SYMBOL(<source>).
      APPEND INITIAL LINE TO lt_less ASSIGNING FIELD-SYMBOL(<target>).
      CLEAR <target>-client.
      <target>-id   = <source>-object_id.
      <target>-type = <source>-process_type.
    ENDLOOP.

    TYPES:
      BEGIN OF struc_less_fields2,
        client       TYPE crmd_orderadm_h-client,
        object_id    TYPE crmd_orderadm_h-object_id,
        process_type TYPE crmd_orderadm_h-process_type,
      END OF struc_less_fields2.
    DATA: lt_less2 TYPE TABLE OF struc_less_fields2.

    LOOP AT mt_orderadm_h ASSIGNING FIELD-SYMBOL(<source2>).
      APPEND INITIAL LINE TO lt_less2 ASSIGNING FIELD-SYMBOL(<target2>).
      <target2>-client        = <source2>-client.
      <target2>-object_id     = <source2>-object_id.
      <target2>-process_type  = <source2>-process_type.
    ENDLOOP.
  ENDMETHOD.


  METHOD filter.
"
***    DATA(lt_orderadm_h_z) = FILTER #( mt_orderadm_h
***                                        WHERE process_type = 'ZYPM' ).
***
***    DATA(lines)           = lines(lt_orderadm_h_z).

  ENDMETHOD.


  method FILTER_OLD.
  endmethod.


  METHOD groupby.
    TYPES:
      BEGIN OF struc_order_count,
        user         TYPE systring,
        process_type TYPE systring,
        counter      TYPE int4,
      END OF struc_order_count
      .
    DATA: lt_counter TYPE TABLE OF struc_order_count,
          lv_counter TYPE int4
          .
    "Counting orders created by users
    LOOP AT mt_orderadm_h ASSIGNING FIELD-SYMBOL(<order>)
      GROUP BY ( created_by = <order>-created_by )
      ASSIGNING FIELD-SYMBOL(<group_by_user>).

      "Only for current user
      CHECK <group_by_user>-created_by EQ sy-uname.

      "Get sum of orders by process type
      LOOP AT GROUP <group_by_user> ASSIGNING FIELD-SYMBOL(<member>)
        GROUP BY <member>-process_type.

        lv_counter = 0.
        LOOP AT GROUP <member> ASSIGNING FIELD-SYMBOL(<member2>).
          "Count orders of a certain process type
          lv_counter = lv_counter + 1.
        ENDLOOP.
        APPEND VALUE #( user         = <group_by_user>-created_by
                        process_type = <member>-process_type
                        counter      = lv_counter ) TO lt_counter.
***        APPEND INITIAL LINE TO lt_counter ASSIGNING FIELD-SYMBOL(<counter>).
***        <counter>-user          = <group_by_user>-created_by.
***        <counter>-process_type  = <member>-process_type.
***        <counter>-counter       = lv_counter.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD is_countable.
    IF iv_created_by EQ sy-uname.
      rv_counter = 1.
    ELSE.
      rv_counter = 0.
    ENDIF.
  ENDMETHOD.


  METHOD line_access.
    DATA: lv_message TYPE string.
    TRY.
        "Check if a line exists
        IF line_exists( mt_proc_type[ process_type = |ZYPK| ] ).
          MESSAGE 'OK' TYPE 'I'.
        ELSE.
          MESSAGE 'Missing process type' TYPE 'E'.
        ENDIF.

        "Getting the index of a line
        DATA(idx) = line_index( mt_proc_type[ process_type = |ZYPK| ] ).
        lv_message = idx.
        lv_message = |Row:{ idx }|.
        MESSAGE lv_message TYPE 'I'.
      CATCH cx_sy_itab_line_not_found INTO DATA(lr_cx).
        "no need to check sy-subrc
    ENDTRY.
  ENDMETHOD.


  METHOD line_access_old.
    "Doing it the old fashioned way...
    READ TABLE mt_proc_type WITH KEY process_type = |ZYPK| TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      MESSAGE 'OK' TYPE 'I'.
    ELSE.
      MESSAGE 'Missing process type' TYPE 'E'.
    ENDIF.
  ENDMETHOD.


  METHOD read.
    TRY.
        DATA(idx) = line_index( mt_proc_type[ process_type = |ZYPK| ] ).
        "Access with index
        mt_proc_type[ idx ]-process_blocked = abap_true.

        "Access by column
        IF mt_proc_type[ process_type = |ZYPK| ]-process_blocked EQ abap_true.
          mt_proc_type[ idx ]-process_blocked = abap_false.
        ENDIF.

        "instead of using a field symbol one can copy values into a variable
        DATA(lv_blocked) = VALUE type( mt_proc_type[ idx ]-process_blocked ).
        lv_blocked = abap_true.
        IF lv_blocked NE mt_proc_type[ idx ]-process_blocked.
          "well in this case we succesfully modefied the value
          "without touching the array
        ENDIF.
      CATCH cx_sy_itab_line_not_found INTO DATA(lr_cx).
        "no more need for sy-subrc checking
    ENDTRY.
  ENDMETHOD.


  METHOD read_old.
    "Doing it the old fashioned way...
    DATA: lv_blocked TYPE abap_bool.

    FIELD-SYMBOLS: <proc_type> LIKE LINE OF mt_proc_type.

    "Example: Read data from itab into field symbol and compare it
    READ TABLE mt_proc_type ASSIGNING <proc_type> WITH KEY process_type = |ZYPK|.
    IF sy-subrc EQ 0.
      IF <proc_type>-process_blocked EQ lv_blocked.
        "equal
      ELSE.
        "unequal
      ENDIF.
    ELSE.
      "Error handling if read failed
    ENDIF.
  ENDMETHOD.


  METHOD reduce.
    "counting entries by a certain user
    "when using methods obey the gold old space
    DATA(count) = REDUCE int4(
                      INIT result = 0
                      FOR line IN mt_orderadm_h
                      NEXT result = result + is_countable( line-created_by ) ).
  ENDMETHOD.


  METHOD reduce_old.
    "counting entries by a certain user
    "the old way
    DATA:           count TYPE int4.
    FIELD-SYMBOLS:  <line> TYPE crmd_orderadm_h.
    LOOP AT mt_orderadm_h ASSIGNING <line>.
      count = count + is_countable( <line>-created_by ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
