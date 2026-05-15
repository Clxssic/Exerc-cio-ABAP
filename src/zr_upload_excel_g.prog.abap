*&---------------------------------------------------------------------*
*& Report ZR_UPLOAD_EXCEL_G
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZR_UPLOAD_EXCEL_G.

INCLUDE zr_upload_excel_g_top.

INCLUDE zr_upload_excel_g_f01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM value_req_file.

START-OF-SELECTION.

PERFORM del.
PERFORM execute.
