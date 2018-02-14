class ZYPL_ITAB_DEMO definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_TABLE_NAME type TABNAME .
  methods LINE_ACCESS .
  methods LINE_ACCESS_OLD .
  methods READ .
PROTECTED SECTION.

  DATA mt_orderadm_h TYPE TABLE OF crmd_orderadm_h .
  DATA mt_proc_type TYPE TABLE OF crmc_proc_type .
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


  METHOD line_access.
    DATA: lv_message TYPE string.

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
    DATA(idx) = line_index( mt_proc_type[ process_type = |ZYPK| ] ).

    TRY.
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
ENDCLASS.
