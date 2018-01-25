REPORT z_demo_string_templ_expression.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" C. Donau, 25.01.2018
" Demo for using embedded expressions in String Templates.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      main,
      return_hello
        IMPORTING
                  i             TYPE i OPTIONAL
        RETURNING VALUE(r_text) TYPE string.

ENDCLASS.

CLASS demo IMPLEMENTATION.

  METHOD main.
    cl_demo_output=>new(
        )->write( |{ demo=>return_hello( ) } world!|
        )->display( ).
  ENDMETHOD.

  METHOD return_hello.
    r_text = |Hello|.
  ENDMETHOD.

ENDCLASS.

END-OF-SELECTION.
  demo=>main( ).
