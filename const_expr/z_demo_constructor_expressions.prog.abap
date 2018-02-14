REPORT z_demo_constructor_expressions.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" C. Donau, 08.02.2018
" Demo for using constructor expressions in ABAP:
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS demo DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          i_description TYPE REF TO string OPTIONAL,
      start_demo.

  PRIVATE SECTION.
    METHODS:
      _0_intro,
      _cond_operator,
      _new_operator,
      _value_operator,
      _value_operator_table,
      _conv_and_cast_operator,
      _give_me_a_string
        IMPORTING
          i_string TYPE string,
      _give_me_an_unsorted_table
        IMPORTING
          i_some_sorted_table TYPE REF TO crmt_object_guid_tab_unsorted.
ENDCLASS.

CLASS demo_child DEFINITION INHERITING FROM demo.
ENDCLASS.

CLASS demo IMPLEMENTATION.

  METHOD start_demo.
    _0_intro( ).
    _value_operator( ).
    _new_operator( ).
    _value_operator( ).
    _conv_and_cast_operator( ).
    _cond_operator( ).
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

  METHOD _cond_operator.
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


  METHOD _new_operator.
    " The instance operator NEW creates an anonymous data object
    " or an instance of a class and assigns values to the new object.
    " The result is a reference variable that points to the new object.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Use new with data types as type
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " With constructor operator
    DATA some_text TYPE REF TO string.
    some_text = NEW string( |Hello World| ).
    " This is the same:
    some_text = NEW #( |Hello World!| ).

    " Equivalent to
    DATA some_other_text TYPE REF TO string.
    FIELD-SYMBOLS <some_other_text> TYPE string.

    CREATE DATA some_other_text TYPE string.
    ASSIGN some_other_text->* TO <some_other_text>.
    <some_other_text> = |Hello World|.


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Use new with classes as type
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " With constructor operator
    DATA(some_class) = NEW demo( ).

    " Equivalent to
    DATA some_other_class TYPE REF TO demo.
    CREATE OBJECT some_other_class TYPE demo.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Use new with # as type
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA some_integer TYPE REF TO i.
    some_integer = NEW #( 5 ).

    " This does not work -> Why?
    " data(some_object) = new #( ).

  ENDMETHOD.

  METHOD constructor.

  ENDMETHOD.


  METHOD _value_operator.
    " The value operator VALUE creates a result of a data type specified.

    " With constructor operator
    DATA(some_structure) = VALUE bapiret2( id = sy-msgid
                                           type = sy-msgty
                                           number = sy-msgno ).

    " Equivalent to
    DATA some_other_structure TYPE bapiret2.
    some_other_structure-id = sy-msgid.
    some_other_structure-type = sy-msgty.
    some_other_structure-number = sy-msgno.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " This gets even better when you construct tables...
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    _value_operator_table( ).

  ENDMETHOD.

  METHOD _value_operator_table.

    DATA(error_messages) = VALUE bapiret2_t( ( id = sy-msgid type = |E| number = 1 )
                                             ( id = sy-msgid type = |W| number = 2 ) ).

    " Equivalent to
    DATA other_error_messages TYPE bapiret2_t.
    DATA error_structure TYPE bapiret2.

    error_structure-id = sy-msgid.
    error_structure-type = |E|.
    error_structure-number = 1.
    APPEND error_structure TO other_error_messages.

    CLEAR error_structure.
    error_structure-id = sy-msgid.
    error_structure-type = |W|.
    error_structure-number = 2.
    APPEND error_structure TO other_error_messages.

  ENDMETHOD.




  METHOD _conv_and_cast_operator.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " The conversion operator CONV is used for conversions between
    " data types in operand positions.

    DATA(some_text) = NEW char220( |Hello SAP Sprint| ).
    _give_me_a_string( CONV #( some_text->* ) ).


    DATA(some_sorted_table) = NEW crmt_object_guid_tab( ).
    _give_me_an_unsorted_table( CONV #( some_sorted_table ) ).


    " Equivalent to
    DATA(some_other_sorted_table) = NEW crmt_object_guid_tab( ).
    DATA(auxiliary_table) = NEW crmt_object_guid_tab_unsorted( ).

    INSERT LINES OF some_other_sorted_table->* INTO TABLE auxiliary_table->*.
    _give_me_an_unsorted_table( auxiliary_table ).


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " The casting operator CAST is used for down casts of reference
    " variables in operand positions.
    DATA parent_class TYPE REF TO demo.
    DATA child_class TYPE REF TO demo_child.

    parent_class = NEW demo_child( ).

    child_class = CAST #( parent_class ).

    " Equivalent to
    child_class ?= parent_class.

    " You can use that stuff in importing / exporting parameters too!

  ENDMETHOD.


  METHOD _give_me_a_string.
    " Do something
  ENDMETHOD.


  METHOD _give_me_an_unsorted_table.
    " Do something
  ENDMETHOD.

ENDCLASS.


END-OF-SELECTION.

  NEW demo( )->start_demo( ).
