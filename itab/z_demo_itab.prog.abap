*&---------------------------------------------------------------------*
*& Report  Z_DEMO_ITAB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT z_demo_itab.

DATA:
  lr_itab_demo TYPE REF TO zypl_itab_demo
  .

PARAMETERS:
  p_read   RADIOBUTTON GROUP itab,
  p_line   RADIOBUTTON GROUP itab,
  p_reduce RADIOBUTTON GROUP itab,
  p_group  RADIOBUTTON GROUP itab,
  p_corre  RADIOBUTTON GROUP itab,
  p_filter RADIOBUTTON GROUP itab,
  p_old    AS CHECKBOX DEFAULT abap_false
  .

START-OF-SELECTION.

  CASE abap_true.
    WHEN p_line.
      CREATE OBJECT lr_itab_demo EXPORTING iv_table_name = |CRMC_PROC_TYPE|.
      IF p_old EQ abap_true.
        BREAK-POINT.
        lr_itab_demo->line_access_old( ).
      ELSE.
        BREAK-POINT.
        lr_itab_demo->line_access( ).
      ENDIF.
    WHEN p_read.
      CREATE OBJECT lr_itab_demo EXPORTING iv_table_name = |CRMC_PROC_TYPE|.
      IF p_old EQ abap_true.
        BREAK-POINT.
        lr_itab_demo->read_old( ).
      ELSE.
        BREAK-POINT.
        lr_itab_demo->read( ).
      ENDIF.
    WHEN p_reduce.
      CREATE OBJECT lr_itab_demo EXPORTING iv_table_name = |CRMD_ORDERADM_H|.
      IF p_old EQ abap_true.
        BREAK-POINT.
        lr_itab_demo->reduce_old( ).
      ELSE.
        BREAK-POINT.
        lr_itab_demo->reduce( ).
      ENDIF.
    WHEN p_filter.
      CREATE OBJECT lr_itab_demo EXPORTING iv_table_name = |CRMD_ORDERADM_H|.
      IF p_old EQ abap_true.
        BREAK-POINT.
        lr_itab_demo->filter_old( ).
      ELSE.
        BREAK-POINT.
        lr_itab_demo->filter( ).
      ENDIF.
    WHEN p_corre.
      CREATE OBJECT lr_itab_demo EXPORTING iv_table_name = |CRMD_ORDERADM_H|.
      IF p_old EQ abap_true.
        BREAK-POINT.
        lr_itab_demo->corresponding_old( ).
      ELSE.
        BREAK-POINT.
        lr_itab_demo->corresponding( ).
      ENDIF.
    WHEN p_group.
      CREATE OBJECT lr_itab_demo EXPORTING iv_table_name = |CRMD_ORDERADM_H|.
      BREAK-POINT.
      lr_itab_demo->groupby( ).
    WHEN OTHERS.
      "to be contuined
  ENDCASE.
