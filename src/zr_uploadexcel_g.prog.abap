*&---------------------------------------------------------------------*
*& Report ZR_UPLOADEXCEL_G
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZR_UPLOADEXCEL_G.

INCLUDE zr_uploadexcel_g_top.

INCLUDE zr_uploadexcel_g_f01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM value_req_file.

START-OF-SELECTION.

  PERFORM execute.
