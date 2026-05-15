*&---------------------------------------------------------------------*
*& Include          ZR_UPLOADEXCEL_G_TOP
*&---------------------------------------------------------------------*
DATA: gt_table  TYPE filetable,
      gt_data_t TYPE STANDARD TABLE OF string,
      gt_c100   TYPE TABLE OF ztb_c100_g,
      gt_c170   TYPE TABLE OF ztb_c170_g.

DATA: gv_rc TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS: p_rdb1 RADIOBUTTON GROUP gr1,
              p_rdb2 RADIOBUTTON GROUP gr1.

  PARAMETERS: p_file TYPE rlgrap-filename.

SELECTION-SCREEN END OF BLOCK b1.
