REPORT zadler32.

TYPES: ty_adler32 TYPE x LENGTH 4.

CLASS lcl_adler32 DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS:
      original
        IMPORTING iv_xstring         TYPE xstring
        RETURNING VALUE(rv_checksum) TYPE ty_adler32,
      test
        IMPORTING iv_xstring         TYPE xstring
        RETURNING VALUE(rv_checksum) TYPE ty_adler32.

ENDCLASS.

CLASS lcl_adler32 IMPLEMENTATION.

  METHOD original.

    CONSTANTS: lc_adler TYPE i VALUE 65521.

    DATA: lv_index TYPE i,
          lv_a     TYPE i VALUE 1,
          lv_b     TYPE i VALUE 0,
          lv_x     TYPE x LENGTH 2,
          lv_ca    TYPE c LENGTH 4,
          lv_cb    TYPE c LENGTH 4,
          lv_char8 TYPE c LENGTH 8.


    DO xstrlen( iv_xstring ) TIMES.
      lv_index = sy-index - 1.

      lv_a = ( lv_a + iv_xstring+lv_index(1) ) MOD lc_adler.
      lv_b = ( lv_b + lv_a ) MOD lc_adler.
    ENDDO.

    lv_x = lv_a.
    lv_ca = lv_x.

    lv_x = lv_b.
    lv_cb = lv_x.

    CONCATENATE lv_cb lv_ca INTO lv_char8.

    rv_checksum = lv_char8.

  ENDMETHOD.

  METHOD test.

    CONSTANTS: lc_adler TYPE i VALUE 65521,
               lc_max_b TYPE i VALUE 1800000000,
               lc_max   TYPE i VALUE 3800.

    DATA: lv_index TYPE i,
          lv_a     TYPE i VALUE 1,
          lv_b     TYPE i VALUE 0,
          lv_x     TYPE x LENGTH 2,
          lv_ca    TYPE c LENGTH 4,
          lv_cb    TYPE c LENGTH 4,
          lv_char8 TYPE c LENGTH 8.


    DO xstrlen( iv_xstring ) TIMES.
      lv_index = sy-index - 1.

      lv_a = lv_a + iv_xstring+lv_index(1).
      lv_b = lv_b + lv_a.

* delay the MOD operation until the integer might overflow
* articles describe 5552 additions are allowed, but this assumes unsigned integers
* instead of allowing a fixed number of additions before running MOD, then
* just compare value of lv_b, this is 1 operation less than comparing and adding
* which will run faster on the ABAP VM
      IF lv_b > lc_max_b.
        lv_a = lv_a MOD lc_adler.
        lv_b = lv_b MOD lc_adler.
      ENDIF.
    ENDDO.

    lv_a = lv_a MOD lc_adler.
    lv_b = lv_b MOD lc_adler.

    lv_x = lv_a.
    lv_ca = lv_x.

    lv_x = lv_b.
    lv_cb = lv_x.

    CONCATENATE lv_cb lv_ca INTO lv_char8.

    rv_checksum = lv_char8.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  DATA: t1      TYPE i,
        t2      TYPE i,
        lv_x    TYPE x LENGTH 1 VALUE 'FF', " 255
        lv_sum  TYPE ty_adler32,
        lv_xstr TYPE xstring.


  GET RUN TIME FIELD t1.
  DO 12000000 TIMES.
    CONCATENATE lv_xstr lv_x INTO lv_xstr IN BYTE MODE.
  ENDDO.
  GET RUN TIME FIELD t2.
  t2 = ( t2 - t1 ).
  WRITE: / 'build data', t2, 'seconds'.

  DO 5 TIMES.
    GET RUN TIME FIELD t1.
    lv_sum = lcl_adler32=>original( lv_xstr ).
    GET RUN TIME FIELD t2.
    t2 = ( t2 - t1 ).
    WRITE: / 'original', t2, 'seconds'.
    WRITE: / lv_sum.

    GET RUN TIME FIELD t1.
    lv_sum = lcl_adler32=>test( lv_xstr ).
    GET RUN TIME FIELD t2.
    t2 = ( t2 - t1 ).
    WRITE: / 'test', t2, 'seconds'.
    WRITE: / lv_sum.
  ENDDO.

ENDFORM.
