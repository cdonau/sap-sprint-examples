REPORT z_demo_constructor_expressions.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" C. Donau, 08.02.2018
" Demo for using constructor expressions in ABAP:
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS demo DEFINITION.
  PUBLIC SECTION.
    METHODS:
      start_demo.

  PRIVATE SECTION.
    METHODS:
      _0_intro,
      _1_cond_operator
      .
ENDCLASS.

CLASS demo IMPLEMENTATION.

  METHOD start_demo.
    _0_intro( ).
    _1_cond_operator( ).
    " _switch_operator

  ENDMETHOD.

  METHOD _0_intro.



*With Release 7.40 ABAP supports so called constructor operators.
* Constructor operators are used in constructor expressions to create a result that can be used at operand positions. The syntax for constructor expressions is
*
* operator type( … ) …
*
*operator is a constructor operator. type is either the explicit name of a data type or the character #. With # the data type can be dreived from the operand
*position if the operand type is statically known. Inside the parentheses specific parameters can be specified.


  ENDMETHOD.

  METHOD _1_cond_operator.
    " https://blogs.sap.com/2013/05/28/abap-news-for-release-740-constructor-operators-cond-and-switch/

* Syntax
* COND dtype|#( WHEN log_exp1 THEN result1
*                [ WHEN log_exp2 THEN result2 ]
*                …
*                [ ELSE resultn ] )
*
* COND = IF in operand position

    DATA(time) =
     COND string(
       WHEN sy-timlo < '120000' THEN
         |{ sy-timlo TIME = ISO } AM|
       WHEN sy-timlo > '120000' THEN
         |{ CONV t( sy-timlo - 12 * 3600 ) TIME = ISO } PM|
       WHEN sy-timlo = '120000' THEN
         |High Noon|
       ELSE
         THROW cx_aab_static( )
    ).

    IF sy-timlo < '120000'.
      time = |{ sy-timlo TIME = ISO } AM|.
    ELSEIF sy-timlo > '120000'.
      time = |{ CONV t( sy-timlo - 12 * 3600 ) TIME = ISO } PM|.
    ELSEIF sy-timlo = '120000'.
      time = |High Noon|.
    ELSE.
      RAISE EXCEPTION TYPE cx_aab_static.
    ENDIF.

  ENDMETHOD.

ENDCLASS.


END-OF-SELECTION.

  NEW demo( )->start_demo( ).
