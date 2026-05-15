*&---------------------------------------------------------------------*
*& Include          ZR_RELATORIO_EXCEL_G_F01
*&---------------------------------------------------------------------*
FORM get_dados.

  SELECT *
    FROM ztb_c100_g
    INTO TABLE gt_header
    WHERE num_doc IN s_numdoc
    AND dt_doc IN s_data
    AND cod_part IN s_parc
    AND cod_mod IN s_mdoc
    AND cod_sit IN s_sit.

  SELECT *
    FROM ztb_c170_g
    INTO TABLE gt_itens
    WHERE num_doc IN s_numdoc
      AND cfop IN s_cfop
      AND num_item IN s_numit
      AND cst_icms IN s_cstic.

ENDFORM.

FORM display_alv USING p_alv_table TYPE ANY TABLE.

  CALL METHOD cl_salv_table=>factory
*    EXPORTING
*      list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
*      r_container    =                           " Abstract Container for GUI Controls
*      container_name =
    IMPORTING
      r_salv_table = go_salv_table                       " Basis Class Simple ALV Tables
    CHANGING
      t_table      = p_alv_table.
*  CATCH cx_salv_msg. " ALV: General Error Class with Message

  IF go_salv_table IS BOUND.

    go_salv_table->display( ).

  ENDIF.

ENDFORM.

FORM cross_data.

  DATA: ls_header    TYPE ztb_c100_g,
        ls_itens     TYPE ztb_c170_g,
        ls_itens_aux TYPE ztb_c170_g,
        ls_alv100    TYPE zst_alv_c100_yas,
        ls_alv170    TYPE zst_alv_c170_yas.

  DATA: lv_soma_itens TYPE p DECIMALS 2,
        lv_diferenca  TYPE p DECIMALS 2.

  SORT gt_header BY num_doc.
  SORT gt_itens  BY num_doc num_item.

  IF p_res = abap_true.

    LOOP AT gt_header INTO ls_header.
      CLEAR ls_alv100.

      ls_alv100-num_doc = ls_header-num_doc.
      ls_alv100-dt_doc = ls_header-dt_doc.
      ls_alv100-cod_part = ls_header-cod_part.
      ls_alv100-cod_mod = ls_header-cod_mod.
      ls_alv100-cod_sit = ls_header-cod_sit.
      ls_alv100-vl_total = ls_header-vl_doc.

      READ TABLE gt_itens TRANSPORTING NO FIELDS
        WITH KEY num_doc = ls_header-num_doc BINARY SEARCH.

      IF sy-subrc = 0.

        CLEAR lv_soma_itens.

        LOOP AT gt_itens INTO ls_itens WHERE num_doc = ls_header-num_doc.
          ls_alv100-quant = ls_alv100-quant + 1.
          lv_soma_itens = lv_soma_itens + ls_itens-vl_item.
        ENDLOOP.

        ls_alv100-soma_it = lv_soma_itens.

        lv_diferenca = ls_header-vl_doc - lv_soma_itens.

        IF lv_diferenca < 0.
          lv_diferenca = lv_diferenca * -1.
        ENDIF.

        ls_alv100-dif_calc = lv_diferenca.

        IF lv_diferenca > p_tol.
          ls_alv100-status_rel = gc_div. "DIVERGENTE
          ls_alv100-obs = gc_erro4. "Valor do header difere da soma dos itens
        ELSE.
          ls_alv100-status_rel = gc_cas. "CASADO
          ls_alv100-obs = gc_erro2. "Header e itens correspondem dentro dos limites
        ENDIF.

      ELSE.

        ls_alv100-dif_calc = ls_header-vl_doc.
        ls_alv100-status_rel = gc_h_s_i. "HEADER_SEM_ITEM
        ls_alv100-obs = gc_erro3. "ITEM_SEM_HEADER

      ENDIF.

      APPEND ls_alv100 TO gt_alvheader.
    ENDLOOP.

  ELSE. "Iniciar o relatório detalhado.

    LOOP AT gt_itens INTO ls_itens.
      CLEAR ls_alv170.

      ls_alv170-num_doc = ls_itens-num_doc.
      ls_alv170-cfop = ls_itens-cfop.
      ls_alv170-num_item = ls_itens-num_item.
      ls_alv170-cst_icms = ls_itens-cst_icms.
      ls_alv170-descr_compl = ls_itens-descr_compl.
      ls_alv170-quant = ls_itens-qtd.
      ls_alv170-unidade = ls_itens-unid.
      ls_alv170-vl_item = ls_itens-vl_item.

      READ TABLE gt_header INTO ls_header
        WITH KEY num_doc = ls_itens-num_doc BINARY SEARCH.

      IF sy-subrc = 0.

        ls_alv170-vl_header = ls_header-vl_doc.
        ls_alv170-dt_doc = ls_header-dt_doc.
        ls_alv170-cod_part = ls_header-cod_part.
        ls_alv170-cod_mod = ls_header-cod_mod.
        ls_alv170-cod_sit = ls_header-cod_sit.

        CLEAR lv_soma_itens.

        LOOP AT gt_itens INTO ls_itens_aux WHERE num_doc = ls_header-num_doc.
          lv_soma_itens = lv_soma_itens + ls_itens_aux-vl_item.
        ENDLOOP.

        lv_diferenca = ls_header-vl_doc - lv_soma_itens.
        IF lv_diferenca < 0.
          lv_diferenca = lv_diferenca * -1.
        ENDIF.

        ls_alv170-soma_it = lv_soma_itens.
        ls_alv170-dif_calc = lv_diferenca.

        IF lv_diferenca > p_tol.
          ls_alv170-status_rel = gc_div. "DIVERGENTE
          ls_alv170-obs = gc_erro4. "Valor do header difere da soma dos itens
        ELSE.
          ls_alv170-status_rel = gc_cas. "CASADO
          ls_alv170-obs = gc_erro5. "Header e itens correspondem dentro da tolerância
        ENDIF.

      ELSE.

        ls_alv170-soma_it = ls_itens-vl_item.
        ls_alv170-dif_calc = ls_itens-vl_item.
        ls_alv170-status_rel = gc_i_s_h. "ITEM_SEM_HEADER
        ls_alv170-obs = gc_erro6. "Produto registrado sem header associado
      ENDIF.

      APPEND ls_alv170 TO gt_alvitens.
    ENDLOOP.
  ENDIF.

ENDFORM.

FORM possibilities.
*p_todos
*p_csd
*p_div
*p_semrel

  IF p_todos = abap_true.
    RETURN.
  ENDIF.

  IF p_res = abap_true.
    IF p_csd = abap_true.
      DELETE gt_alvheader WHERE status_rel <> gc_cas. "CASADO
    ELSEIF p_div = abap_true.
      DELETE gt_alvheader WHERE status_rel <> gc_div. "DIVERGENTE
    ELSEIF p_semrel = abap_true.
      DELETE gt_alvheader WHERE status_rel <> gc_h_s_i "HEADER_SEM_ITEM
      AND status_rel <> gc_i_s_h. "ITEM_SEM_HEADER
    ENDIF.

  ELSE.

    IF p_csd = abap_true.
      DELETE gt_alvitens WHERE status_rel <> gc_cas. "CASADO
    ELSEIF p_div = abap_true.
      DELETE gt_alvitens WHERE status_rel <> gc_div. "DIVERGENTE
    ELSEIF p_semrel = abap_true.
      DELETE gt_alvitens WHERE status_rel <> gc_h_s_i "HEADER_SEM_ITEM
      AND status_rel <> gc_i_s_h. "ITEM_SEM_HEADER

    ENDIF.
  ENDIF.
ENDFORM.
FORM execute.

  PERFORM get_dados.
  PERFORM cross_data.
  PERFORM possibilities.

  IF p_res = abap_true.
    PERFORM display_alv USING gt_alvheader.
  ELSE.
    PERFORM display_alv USING gt_alvitens.
  ENDIF.

ENDFORM.
