*&---------------------------------------------------------------------*
*& Report  Z_DEMO_ITAB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT z_demo_itab.
TYPES:
  BEGIN OF struc_count_order,
    user         TYPE systring,
    process_type TYPE systring,
    counter      TYPE int4,
  END OF struc_count_order
  .
DATA:
  lv_message TYPE systring,
  lv_counter TYPE int4,
  lt_counter TYPE TABLE OF struc_count_order
  .

PARAMETERS:
  p_break AS CHECKBOX DEFAULT abap_true,
  p_old   AS CHECKBOX DEFAULT abap_false,
  p_line  RADIOBUTTON GROUP itab,
  p_group RADIOBUTTON GROUP itab
  .

START-OF-SELECTION.

  SELECT * FROM crmc_proc_type  INTO TABLE @DATA(lt_table).
  SELECT * FROM crmd_orderadm_h INTO TABLE @DATA(lt_table2).

  CASE abap_true.
    WHEN p_group.
      IF p_break EQ abap_true.
        BREAK-POINT.
      ENDIF.
**********************************************************************
*** LOOP with GROUP BY
**********************************************************************
      "Counting orders created by users
      LOOP AT lt_table2 ASSIGNING FIELD-SYMBOL(<group>) GROUP BY <group>-created_by.
        "User
        LOOP AT GROUP <group> ASSIGNING FIELD-SYMBOL(<member>) GROUP BY <member>-process_type.
          "process type
          lv_counter = 0.
          LOOP AT GROUP <member> ASSIGNING FIELD-SYMBOL(<member2>).
            "Count orders of a certain process type
            lv_counter = lv_counter + 1.
          ENDLOOP.
          APPEND INITIAL LINE TO lt_counter ASSIGNING FIELD-SYMBOL(<counter>).
          <counter>-user          = <group>-created_by.
          <counter>-process_type  = <member>-process_type.
          <counter>-counter       = lv_counter.
        ENDLOOP.
      ENDLOOP.

      BREAK-POINT.
      REFRESH lt_counter.

      LOOP AT lt_table2 ASSIGNING FIELD-SYMBOL(<group_key>)
        GROUP BY ( created_by = sy-uname ) ASSIGNING FIELD-SYMBOL(<group_key2>).

        lv_counter = 0.
        LOOP AT GROUP <group_key2> ASSIGNING FIELD-SYMBOL(<member_key>)
          GROUP BY <member_key>-process_type.
          lv_counter = lv_counter + 1.
        ENDLOOP.
          APPEND INITIAL LINE TO lt_counter ASSIGNING FIELD-SYMBOL(<counter2>).
          <counter2>-user          = sy-uname.
          <counter2>-process_type  = <member_key>-process_type.
          <counter2>-counter       = lv_counter.
      ENDLOOP.

      BREAK-POINT.

    WHEN p_line.
      IF p_break EQ abap_true.
        BREAK-POINT.
      ENDIF.
**********************************************************************
*** LINE_EXISTS & LINE_INDEX
**********************************************************************
      IF p_old EQ abap_false.
        "Checking if a line exists
        IF line_exists( lt_table[ process_type = |ZYPK| ] ).
          MESSAGE 'OK' TYPE 'I'.
        ELSE.
          MESSAGE 'Missing process type' TYPE 'E'.
        ENDIF.
      ELSE.
        "Doing it the old fashioned way...
        READ TABLE lt_table WITH KEY process_type = |ZYPK| TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          MESSAGE 'OK' TYPE 'I'.
        ELSE.
          MESSAGE 'Missing process type' TYPE 'E'.
        ENDIF.
      ENDIF.
      IF p_old EQ abap_false.
        "Getting the index of a line
        DATA(idx) = line_index( lt_table[ process_type = |ZYPK| ] ).
        lv_message = idx.
        lv_message = |Row:{ idx }|.
        MESSAGE lv_message TYPE 'I'.
      ELSE.
        MESSAGE 'Sorry no example' TYPE 'W'.
      ENDIF.
    WHEN OTHERS.
      "to be contuined
  ENDCASE.
