REPORT z_demo_string_templ_expression.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" C. Donau, 25.01.2018
" Demo for using embedded expressions in String Templates.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      main,
      return_echo
        IMPORTING
                  i_iter        TYPE i
        RETURNING VALUE(r_echo) TYPE string,
      return_hello
        RETURNING VALUE(r_text) TYPE string.

ENDCLASS.

CLASS demo IMPLEMENTATION.

  METHOD main.
    cl_demo_output=>new(
        )->write( |Hello world!|
        )->write( |{ demo=>return_hello( ) } world!|
        )->write( |My echo:{ demo=>return_echo( 4 ) }|
        )->display( ).
  ENDMETHOD.

  METHOD return_hello.
    r_text = |Hello|.
  ENDMETHOD.

  METHOD return_echo.
    CLEAR r_echo.

    DO i_iter TIMES.
      r_echo = |{ r_echo } Echo|.
    ENDDO.
  ENDMETHOD.

ENDCLASS.

END-OF-SELECTION.
  demo=>main( ).
