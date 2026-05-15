*&---------------------------------------------------------------------*
*& Include          ZR_UPLOAD_EXCEL_G_F01
*&---------------------------------------------------------------------*
FORM del.

  IF p_del = 'X'.
    IF p_rdb1 = abap_true.
      DELETE FROM ztb_c100_g.
      COMMIT WORK.
    ELSE.
      IF p_rdb2 = abap_true.
        DELETE FROM ztb_c170_g.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

FORM value_req_file.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      default_extension       = 'CSV'
      file_filter             = 'Arquivos CSV (*.csv) | *.csv'
    CHANGING
      file_table              = gt_table
      rc                      = gv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5
  ).

  IF sy-subrc = 0.

    FIELD-SYMBOLS: <fs_table1> TYPE file_table.
    READ TABLE gt_table ASSIGNING <fs_table1> INDEX 1.

    IF <fs_table1> IS ASSIGNED.
      p_file = <fs_table1>-filename.
    ENDIF.

    READ TABLE gt_table ASSIGNING FIELD-SYMBOL(<fs_table>) INDEX 1.

    IF <fs_table> IS ASSIGNED.
      p_file = <fs_table>-filename.
    ENDIF.

    DATA: ls_table TYPE file_table.
    READ TABLE gt_table INTO ls_table INDEX 1.

    p_file = ls_table-filename.

    p_file = VALUE #( gt_table[ 1 ]-filename OPTIONAL ).
* INCLUIR mais linhas nisso?

  ENDIF.

ENDFORM.

FORM upload_file USING p_file TYPE string.

  CLEAR: gt_data_t.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = p_file
      filetype                = 'ASC'
      has_field_separator     = ';'
    TABLES
      data_tab                = gt_data_t
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.

FORM check_values_c100 CHANGING cs_zstc100 TYPE zst_stc100_g.

  DATA: lv_value_check TYPE domvalue_l VALUE 'A'.

  DATA: lt_values TYPE TABLE OF dd07v.

  DATA: ls_dom_values TYPE dd07v.

  SELECT *
    FROM dd07v
    INTO TABLE lt_values
    WHERE domname IN ('ZDIND_OPER_G', 'ZD_IND_PGTO_G', 'ZD_IND_FRT_G', 'ZDIND_EMIT_G')
    AND ddlanguage = sy-langu.

  IF sy-subrc = 0.
    READ TABLE lt_values INTO ls_dom_values WITH KEY domvalue_l = lv_value_check.

    IF sy-subrc = 0.
      cs_zstc100-status               = abap_false.
      cs_zstc100-mensagem             = 'Erro!'.
    ELSE.
      cs_zstc100-status               = abap_true.
      cs_zstc100-mensagem             = 'Sucesso!'.
    ENDIF.
  ENDIF.

ENDFORM.

FORM check_values_c170 CHANGING cs_zstc170 TYPE zst_item_log_yas.

  DATA: lv_value_check TYPE domvalue_l VALUE 'A',
        lt_values      TYPE TABLE OF dd07v,
        ls_dom_values  TYPE dd07v.

  SELECT *
    FROM dd07v
    INTO TABLE lt_values
    WHERE domname IN ('ZD_IND_MOV_G', 'ZD_IND_APUR_G')
    AND ddlanguage = sy-langu.

  IF sy-subrc = 0.

    READ TABLE lt_values INTO ls_dom_values WITH KEY domvalue_l = lv_value_check.

    IF sy-subrc = 0.
      cs_zstc170-status               = abap_false.
      cs_zstc170-mensagem             = 'Erro!'.

    ELSE.
      cs_zstc170-status               = abap_true.
      cs_zstc170-mensagem             = 'Sucesso!'.

    ENDIF.
  ENDIF.

ENDFORM.

FORM c100 USING is_string TYPE zst_string_g.


  DATA: ls_c100    TYPE ztb_c100_g,
        ls_zstc100 TYPE zst_stc100_g.

  DATA: lv_data_min TYPE zst_stc100_g-dt_doc,
        lv_data_max TYPE zst_stc100_g-dt_doc,
        lv_dt_doc   TYPE zst_stc100_g-dt_doc,
        lv_dt_e_s   TYPE zst_stc100_g-dt_e_s.

        lv_data_min = '19700101'.
        lv_data_max = '20300101'.

  IF is_string IS NOT INITIAL.

    IF ls_zstc100-reg = 'C100' AND ls_zstc100-num_doc IS INITIAL.
      ls_zstc100-status               = abap_false.
      ls_zstc100-mensagem             = 'Erro!'.
    ELSE.
      ls_zstc100-status               = abap_true.
      ls_zstc100-mensagem             = 'Sucesso!'.
    ENDIF.

    ls_zstc100-usuario              = sy-uname.
    ls_zstc100-data                 = sy-datum.
    ls_zstc100-hora                 = sy-uzeit.
    ls_zstc100-reg                  = is_string-campo1.
    ls_zstc100-ind_oper             = is_string-campo2.
    ls_zstc100-ind_emit             = is_string-campo3.
    ls_zstc100-cod_part             = is_string-campo4.
    ls_zstc100-cod_mod              = is_string-campo5.
    ls_zstc100-cod_sit              = is_string-campo6.
    ls_zstc100-num_doc              = is_string-campo7.
    ls_zstc100-dt_doc               = is_string-campo8.
    ls_zstc100-dt_e_s               = is_string-campo9.
    ls_zstc100-vl_doc               = is_string-campo10.
    ls_zstc100-ind_pgto             = is_string-campo11.
    ls_zstc100-ind_frt              = is_string-campo12.
    ls_zstc100-chv_nfe              = is_string-campo13.
    ls_zstc100-ser                  = is_string-campo14.
    ls_zstc100-vl_desc              = is_string-campo15.
    ls_zstc100-vl_abat_nt           = is_string-campo16.
    ls_zstc100-vl_merc              = is_string-campo17.
    ls_zstc100-vl_frt               = is_string-campo18.
    ls_zstc100-vl_seg               = is_string-campo19.
    ls_zstc100-vl_out_da            = is_string-campo20.
    ls_zstc100-vl_bc_icms           = is_string-campo21.
    ls_zstc100-vl_icms              = is_string-campo22.
    ls_zstc100-vl_bc_icms_st        = is_string-campo23.
    ls_zstc100-vl_icms_st           = is_string-campo24.
    ls_zstc100-vl_ipi               = is_string-campo25.
    ls_zstc100-vl_pis               = is_string-campo26.
    ls_zstc100-vl_cofins            = is_string-campo27.
    ls_zstc100-vl_pis_st            = is_string-campo28.
    ls_zstc100-vl_cofins_st         = is_string-campo29.

    IF ls_zstc100-status = abap_true.
      TRY.

          ls_c100-reg                     = is_string-campo1.
          ls_c100-ind_oper                = is_string-campo2.
          ls_c100-vl_ind_emit             = is_string-campo3.
          ls_c100-cod_part                = is_string-campo4.
          ls_c100-cod_mod                 = is_string-campo5.
          ls_c100-cod_sit                 = is_string-campo6.
          ls_c100-num_doc                 = is_string-campo7.
          ls_c100-dt_doc                  = ls_zstc100-dt_doc.
          ls_c100-dt_e_s                  = ls_zstc100-dt_e_s.
          ls_c100-vl_doc                  = is_string-campo10.
          ls_c100-ind_pgto                = is_string-campo11.
          ls_c100-ind_frt                 = is_string-campo12.
          ls_c100-chv_nfe                 = is_string-campo13.
          ls_c100-ser                     = is_string-campo14.
          ls_c100-vl_desc                 = is_string-campo15.
          ls_c100-vl_abat_nt              = is_string-campo16.
          ls_c100-vl_merc                 = is_string-campo17.
          ls_c100-vl_frt                  = is_string-campo18.
          ls_c100-vl_seg                  = is_string-campo19.
          ls_c100-vl_out_da               = is_string-campo20.
          ls_c100-vl_bc_icms              = is_string-campo21.
          ls_c100-vl_icms                 = is_string-campo22.
          ls_c100-vl_bc_icms_st           = is_string-campo23.
          ls_c100-vl_icms_st              = is_string-campo24.
          ls_c100-vl_ipi                  = is_string-campo25.
          ls_c100-vl_pis                  = is_string-campo26.
          ls_c100-vl_cofins               = is_string-campo27.
          ls_c100-vl_pis_st               = is_string-campo28.
          ls_c100-vl_cofins_st            = is_string-campo29.

          DATA(lv_ano) = is_string-campo8+4(4).
          DATA(lv_mes) = is_string-campo8+2(2).
          DATA(lv_dia) = is_string-campo8(2).

          CONCATENATE lv_ano lv_mes lv_dia INTO DATA(lv_datacerta).
          ls_zstc100-dt_doc = lv_datacerta.
          lv_ano = is_string-campo9+4(4).
          lv_mes = is_string-campo9+2(2).
          lv_dia = is_string-campo9(2).

          CONCATENATE lv_ano lv_mes lv_dia INTO lv_datacerta.
          ls_zstc100-dt_e_s = lv_datacerta.

          IF (  ls_zstc100-dt_doc NOT BETWEEN lv_data_min AND lv_data_max ) OR (  ls_zstc100-dt_doc NOT BETWEEN  lv_data_min AND lv_data_max ).
            ls_zstc100-status = abap_false.
            ls_zstc100-mensagem = 'DATA INVÁLIDA'.

            APPEND ls_zstc100 TO gt_zstc100.
            RETURN.
          ENDIF.

*         PERFORM check_fields_c100 USING ls_c100.

          PERFORM check_values_c100 CHANGING ls_zstc100.
          IF ls_zstc100-status    =       abap_true.

            APPEND ls_zstc100 TO gt_zstc100.
            APPEND ls_c100 TO gt_c100.

          ELSE.

            ls_zstc100-status                  = abap_false.
            ls_zstc100-mensagem                = 'Algum campo chave está preenchido incorretamente'.

          ENDIF.

        CATCH cx_root INTO DATA(lo_root).


          DATA(lv_message) = lo_root->get_text( ).

          ls_zstc100-status                  = abap_false.
          ls_zstc100-mensagem                = lv_message.

          APPEND ls_zstc100 TO gt_zstc100.


      ENDTRY.
    ENDIF.
  ENDIF.
ENDFORM.


FORM c170 USING is_string TYPE zst_string_g.

  DATA: ls_c170    TYPE ztb_c170_g,
        ls_zstc170 TYPE zst_item_log_yas.

  IF is_string IS NOT INITIAL.

    IF ls_zstc170-reg  = 'C170'
      AND ls_zstc170-num_item IS INITIAL
      AND ls_zstc170-cod_item IS INITIAL
      AND ls_zstc170-vl_item IS INITIAL
      AND ls_zstc170-cfop  IS INITIAL
      AND ls_zstc170-cst_pis IS INITIAL
      AND ls_zstc170-cst_cofins IS INITIAL.

      ls_zstc170-status             = abap_false.
      ls_zstc170-mensagem             = 'Erro!'.
    ELSE.
      ls_zstc170-status                = abap_true.
      ls_zstc170-mensagem           = 'Sucesso!'.
    ENDIF.

    ls_zstc170-usuario             = sy-uname.
    ls_zstc170-data                = sy-datum.
    ls_zstc170-hora                = sy-uzeit.
    ls_zstc170-reg                 = is_string-campo1.
    ls_zstc170-num_item            = is_string-campo2.
    ls_zstc170-cod_item            = is_string-campo3.
    ls_zstc170-vl_item             = is_string-campo4.
    ls_zstc170-cfop                = is_string-campo5.
    ls_zstc170-cst_pis             = is_string-campo6.
    ls_zstc170-cst_cofins          = is_string-campo7.
    ls_zstc170-num_doc             = is_string-campo8.
    ls_zstc170-descr_co_mpl        = is_string-campo9.
    ls_zstc170-qtd                 = is_string-campo10.
    ls_zstc170-unid                = is_string-campo11.
    ls_zstc170-vl_desc             = is_string-campo12.
    ls_zstc170-ind_mov             = is_string-campo13.
    ls_zstc170-cst_icms            = is_string-campo14.
    ls_zstc170-cod_nat             = is_string-campo15.
    ls_zstc170-vl_bc_icms          = is_string-campo16.
    ls_zstc170-aliq_icms           = is_string-campo17.
    ls_zstc170-vl_icms             = is_string-campo18.
    ls_zstc170-vl_bc_icms_st       = is_string-campo19.
    ls_zstc170-aliq_st             = is_string-campo20.
    ls_zstc170-vl_icms_st          = is_string-campo21.
    ls_zstc170-ind_apur            = is_string-campo22.
    ls_zstc170-cst_ipi             = is_string-campo23.
    ls_zstc170-cod_enq             = is_string-campo24.
    ls_zstc170-vl_bc_ipi           = is_string-campo25.
    ls_zstc170-aliq_ipi            = is_string-campo26.
    ls_zstc170-vl_ipi              = is_string-campo27.
    ls_zstc170-vl_bc_pis           = is_string-campo28.
    ls_zstc170-aliq_pis            = is_string-campo29.
    ls_zstc170-quant_bc_pis        = is_string-campo30.
    ls_zstc170-aliq_pis_quant      = is_string-campo31.
    ls_zstc170-vl_pis              = is_string-campo32.
    ls_zstc170-vl_bc_cofins        = is_string-campo33.
    ls_zstc170-aliq_cofins         = is_string-campo34.
    ls_zstc170-quant_bc_cofins     = is_string-campo35.
    ls_zstc170-aliq_cofins_quant   = is_string-campo36.
    ls_zstc170-vl_cofins           = is_string-campo37.
    ls_zstc170-cod_cta             = is_string-campo38.


    TRY.

        ls_c170-reg                 = is_string-campo1.
        ls_c170-num_item            = is_string-campo2.
        ls_c170-cod_item            = is_string-campo3.
        ls_c170-vl_item             = is_string-campo4.
        ls_c170-cfop                = is_string-campo5.
        ls_c170-cst_pis             = is_string-campo6.
        ls_c170-cst_cofins          = is_string-campo7.
        ls_c170-num_doc             = is_string-campo8.
        ls_c170-descr_compl         = is_string-campo9.
        ls_c170-qtd                 = is_string-campo10.
        ls_c170-unid                = is_string-campo11.
        ls_c170-vl_desc             = is_string-campo12.
        ls_c170-ind_mov             = is_string-campo13.
        ls_c170-cst_icms            = is_string-campo14.
        ls_c170-cod_nat             = is_string-campo15.
        ls_c170-vl_bc_icms          = is_string-campo16.
        ls_c170-aliq_icms           = is_string-campo17.
        ls_c170-vl_icms             = is_string-campo18.
        ls_c170-vl_bc_icms_st       = is_string-campo19.
        ls_c170-aliq_st             = is_string-campo20.
        ls_c170-vl_icms_st          = is_string-campo21.
        ls_c170-ind_apur            = is_string-campo22.
        ls_c170-cst_ipi             = is_string-campo23.
        ls_c170-cod_enq             = is_string-campo24.
        ls_c170-vl_bc_ipi           = is_string-campo25.
        ls_c170-aliq_ipi            = is_string-campo26.
        ls_c170-vl_ipi              = is_string-campo27.
        ls_c170-vl_bc_pis           = is_string-campo28.
        ls_c170-aliq_pis            = is_string-campo29.
        ls_c170-quant_bc_pis        = is_string-campo30.
        ls_c170-aliq_pis_quant      = is_string-campo31.
        ls_c170-vl_pis              = is_string-campo32.
        ls_c170-vl_bc_cofins        = is_string-campo33.
        ls_c170-aliq_cofins         = is_string-campo34.
        ls_c170-quant_bc_cofins     = is_string-campo35.
        ls_c170-aliq_cofins_quant   = is_string-campo36.
        ls_c170-vl_cofins           = is_string-campo37.
        ls_c170-cod_cta             = is_string-campo38.



        PERFORM check_values_c170 CHANGING ls_zstc170.
        IF ls_zstc170-status    =       abap_true.

          APPEND ls_zstc170 TO gt_zstc170.
          APPEND ls_c170 TO gt_c170.

        ELSE.


          ls_zstc170-status                  = abap_false.
          ls_zstc170-mensagem                = 'Algum campo chave está preenchido incorretamente'.

          APPEND ls_zstc170 TO gt_zstc170.

        ENDIF.

      CATCH cx_root INTO DATA(lo_root).


        DATA(lv_message) = lo_root->get_text( ).

        ls_zstc170-status                  = abap_false.
        ls_zstc170-mensagem                = lv_message.

        APPEND ls_zstc170 TO gt_zstc170.
    ENDTRY.
  ENDIF.
ENDFORM.

FORM save_info_c100.

  INSERT ztb_c100_g FROM TABLE gt_c100.

  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE s018(zaugusto).
  ELSE.
    ROLLBACK WORK.
    MESSAGE e019(zaugusto).
  ENDIF.

ENDFORM.

FORM save_info_c170.

  INSERT ztb_c170_g FROM TABLE gt_c170.

  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE s018(zaugusto).
  ELSE.
    ROLLBACK WORK.
    MESSAGE e019(zaugusto).
  ENDIF.

ENDFORM.


FORM process_file.

  DATA: ls_string TYPE zst_string_g.

  CLEAR gt_c100.
  CLEAR gt_c170.

  LOOP AT gt_data_t ASSIGNING FIELD-SYMBOL(<fs_data_tab>).

    IF sy-tabix > 1.


      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN <fs_data_tab> WITH ''.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN <fs_data_tab> WITH ''.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN <fs_data_tab> WITH ''.

      SPLIT <fs_data_tab> AT ';' INTO TABLE DATA(lt_fields).

      IF lt_fields IS NOT INITIAL.

        CLEAR: ls_string.

        ls_string-campo1  = VALUE #( lt_fields[ 1 ]  OPTIONAL ).
        ls_string-campo2  = VALUE #( lt_fields[ 2 ]  OPTIONAL ).
        ls_string-campo3  = VALUE #( lt_fields[ 3 ]  OPTIONAL ).
        ls_string-campo4  = VALUE #( lt_fields[ 4 ]  OPTIONAL ).
        ls_string-campo5  = VALUE #( lt_fields[ 5 ]  OPTIONAL ).
        ls_string-campo6  = VALUE #( lt_fields[ 6 ]  OPTIONAL ).
        ls_string-campo7  = VALUE #( lt_fields[ 7 ]  OPTIONAL ).
        ls_string-campo8  = VALUE #( lt_fields[ 8 ]  OPTIONAL ).
        ls_string-campo9  = VALUE #( lt_fields[ 9 ]  OPTIONAL ).
        ls_string-campo10 = VALUE #( lt_fields[ 10 ] OPTIONAL ).
        ls_string-campo11 = VALUE #( lt_fields[ 11 ] OPTIONAL ).
        ls_string-campo12 = VALUE #( lt_fields[ 12 ] OPTIONAL ).
        ls_string-campo13 = VALUE #( lt_fields[ 13 ] OPTIONAL ).
        ls_string-campo14 = VALUE #( lt_fields[ 14 ] OPTIONAL ).
        ls_string-campo15 = VALUE #( lt_fields[ 15 ] OPTIONAL ).
        ls_string-campo16 = VALUE #( lt_fields[ 16 ] OPTIONAL ).
        ls_string-campo17 = VALUE #( lt_fields[ 17 ] OPTIONAL ).
        ls_string-campo18 = VALUE #( lt_fields[ 18 ] OPTIONAL ).
        ls_string-campo19 = VALUE #( lt_fields[ 19 ] OPTIONAL ).
        ls_string-campo20 = VALUE #( lt_fields[ 20 ] OPTIONAL ).
        ls_string-campo21 = VALUE #( lt_fields[ 21 ] OPTIONAL ).
        ls_string-campo22 = VALUE #( lt_fields[ 22 ] OPTIONAL ).
        ls_string-campo23 = VALUE #( lt_fields[ 23 ] OPTIONAL ).
        ls_string-campo24 = VALUE #( lt_fields[ 24 ] OPTIONAL ).
        ls_string-campo25 = VALUE #( lt_fields[ 25 ] OPTIONAL ).
        ls_string-campo26 = VALUE #( lt_fields[ 26 ] OPTIONAL ).
        ls_string-campo27 = VALUE #( lt_fields[ 27 ] OPTIONAL ).
        ls_string-campo28 = VALUE #( lt_fields[ 28 ] OPTIONAL ).
        ls_string-campo29 = VALUE #( lt_fields[ 29 ] OPTIONAL ).
        ls_string-campo30 = VALUE #( lt_fields[ 30 ] OPTIONAL ).
        ls_string-campo31 = VALUE #( lt_fields[ 31 ] OPTIONAL ).
        ls_string-campo32 = VALUE #( lt_fields[ 32 ] OPTIONAL ).
        ls_string-campo33 = VALUE #( lt_fields[ 33 ] OPTIONAL ).
        ls_string-campo34 = VALUE #( lt_fields[ 34 ] OPTIONAL ).
        ls_string-campo35 = VALUE #( lt_fields[ 35 ] OPTIONAL ).
        ls_string-campo36 = VALUE #( lt_fields[ 36 ] OPTIONAL ).
        ls_string-campo37 = VALUE #( lt_fields[ 37 ] OPTIONAL ).

        IF p_rdb1 = abap_true.
          PERFORM c100 USING ls_string.
        ELSE.
          PERFORM c170 USING ls_string.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

  IF gt_c100 IS NOT INITIAL.
    PERFORM save_info_c100.
  ELSEIF gt_c170 IS NOT INITIAL.
    PERFORM save_info_c170.
  ENDIF.

ENDFORM.

FORM display-alv-c100.

  CALL METHOD cl_salv_table=>factory
*  EXPORTING
*    list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
*    r_container    =                           " Abstract Container for GUI Controls
*    container_name =
    IMPORTING
      r_salv_table = go_salv_table                        " Basis Class Simple ALV Tables
    CHANGING
      t_table      = gt_zstc100.
  .
* CATCH cx_salv_msg. " ALV: General Error Class with Message

  IF go_salv_table IS BOUND.

    go_salv_table->display( ).

  ENDIF.

ENDFORM.

FORM display-alv-c170.

  CALL METHOD cl_salv_table=>factory
*  EXPORTING
*    list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
*    r_container    =                           " Abstract Container for GUI Controls
*    container_name =
    IMPORTING
      r_salv_table = go_salv_table                        " Basis Class Simple ALV Tables
    CHANGING
      t_table      = gt_zstc170.
  .
* CATCH cx_salv_msg. " ALV: General Error Class with Message

  IF go_salv_table IS BOUND.

    go_salv_table->display( ).

  ENDIF.

ENDFORM.

FORM execute.

  DATA(lv_file) = CONV string( p_file ).

  PERFORM upload_file USING lv_file.

  PERFORM process_file.

  IF p_rdb1 = abap_true.
    PERFORM display-alv-c100.
  ELSEIF p_rdb2 = abap_true.
    PERFORM display-alv-c170.
  ENDIF.

ENDFORM.
