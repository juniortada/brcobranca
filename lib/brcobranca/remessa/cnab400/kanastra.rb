# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab400
      class Kanastra < Brcobranca::Remessa::Cnab400::Base
        VALOR_EM_REAIS = '1'
        VALOR_EM_PERCENTUAL = '2'

        validates_presence_of :agencia, :conta_corrente, message: 'não pode estar em branco.'
        validates_presence_of :documento_cedente, :digito_conta, message: 'não pode estar em branco.'
        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 3, message: 'deve ter no máximo 3 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'

        # Nova instancia do Itau
        def initialize(campos = {})
          campos = { aceite: 'N' }.merge!(campos)
          super(campos)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(5, '0') if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(3, '0') if valor
        end

        def cod_banco
          '559'
        end

        def nome_banco
          'KANASTRA'.ljust(15, ' ')
        end

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          # CAMPO            TAMANHO
          # agencia          4
          # complemento      2
          # conta corrente   5
          # digito da conta  1
          # complemento      8
          "#{agencia}00#{conta_corrente}#{digito_conta}#{''.rjust(8, ' ')}"
        end

        # Complemento do header
        # (no caso do Itau, sao apenas espacos em branco)
        #
        # @return [String]
        #
        def complemento
          ''.rjust(294, ' ')
        end

        # Codigo da carteira de acordo com a documentacao o Itau
        # se a carteira nao forem as testadas (150, 191 e 147)
        # retorna 'I' que é o codigo das carteiras restantes na documentacao
        #
        # @return [String]
        #
        def codigo_carteira
          return 'U' if carteira.to_s == '150'
          return '1' if carteira.to_s == '191'
          return 'E' if carteira.to_s == '147'

          'I'
        end

        # Detalhe do arquivo
        #
        # @param pagamento [PagamentoCnab400]
        #   objeto contendo as informacoes referentes ao boleto (valor, vencimento, cliente)
        # @param sequencial
        #   num. sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '1'                                                     # 001-001 Identificação do registro     9[01]
          detalhe << ''.rjust(5, ' ')                                       # 002-006 Agência débito (brancos)     X[05]
          detalhe << ''.rjust(1, ' ')                                       # 007-007 Dígito agência (brancos)     X[01]
          detalhe << ''.rjust(5, ' ')                                       # 008-012 Razão conta corrente (brancos)X[05]
          detalhe << ''.rjust(7, ' ')                                       # 013-019 Conta corrente (brancos)     X[07]
          detalhe << ''.rjust(1, ' ')                                       # 020-020 Dígito conta (brancos)       X[01]
          detalhe << '0'                                                    # 021-021 Zero fixo                    9[01]
          detalhe << carteira.to_s.rjust(3, '0')                            # 022-024 Código carteira              9[03]
          detalhe << agencia.to_s.rjust(5, '0')                             # 025-029 Agência (sem DV)             9[05]
          detalhe << conta_corrente.to_s.rjust(7, '0')                      # 030-036 Conta corrente (sem DV)       9[07]
          detalhe << digito_conta                                           # 037-037 Dígito conta                 9[01]
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25)           # 038-062 Nº controle participante     X[25]
          detalhe << ''.rjust(3, ' ')                                       # 063-065 Cód banco débito (brancos)   X[03]
          detalhe << (pagamento.codigo_multa == '0' ? '0' : '2')            # 066-066 Campo multa (0=sem, 2=com)    X[01]
          detalhe << (pagamento.codigo_multa == '0' ? ''.rjust(4, ' ') :    # 067-070 % multa (se 066=2)           9[04]
                     pagamento.formata_percentual_multa(4))
          detalhe << pagamento.nosso_numero.to_s.rjust(11, '0')             # 071-081 Identificação título no banco 9[11]
          detalhe << ''.rjust(1, ' ')                                       # 082-082 Dígito auto conferência      X[01]
          detalhe << ''.rjust(10, ' ')                                      # 083-092 Desconto bonificação (brancos)X[10]
          detalhe << '1'                                                    # 093-093 Condição emissão (1=banco)    X[01]
          detalhe << ''.rjust(1, ' ')                                       # 094-094 Emite boleto débito (brancos)X[01]
          detalhe << ''.rjust(10, ' ')                                      # 095-104 Identificação operação (brancos)X[10]
          detalhe << ''.rjust(1, ' ')                                       # 105-105 Indicador rateio (brancos)    X[01]
          detalhe << ''.rjust(1, ' ')                                       # 106-106 Aviso débito automático (brancos)X[01]
          detalhe << ''.rjust(2, ' ')                                       # 107-108 Qtd pagamentos possíveis (brancos)X[02]
          detalhe << pagamento.identificacao_ocorrencia                     # 109-110 Identificação ocorrência      9[02]
          detalhe << pagamento.numero.to_s.rjust(10, '0')                   # 111-120 Número documento             X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # 121-126 Data vencimento               9[06]
          detalhe << pagamento.formata_valor                                # 127-139 Valor título                  9[13]
          detalhe << ''.rjust(3, ' ')                                       # 140-142 Banco cobrador (brancos)      X[03]
          detalhe << ''.rjust(5, ' ')                                       # 143-147 Agência depositária (brancos) X[05]
          detalhe << pagamento.especie_titulo                               # 148-149 Espécie título               X[02]
          detalhe << ''.rjust(1, ' ')                                       # 150-150 Identificação (brancos)       X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # 151-156 Data emissão                  9[06]
          detalhe << ''.rjust(2, ' ')                                       # 157-158 1a instrução (brancos)        X[02]
          detalhe << ''.rjust(2, ' ')                                       # 159-160 2a instrução (brancos)        X[02]
          detalhe << pagamento.formata_valor_mora                           # 161-173 Valor mora dia                9[13]
          detalhe << pagamento.formata_data_desconto                        # 174-179 Data limite desconto          9[06]
          detalhe << pagamento.formata_valor_desconto                       # 180-192 Valor desconto                9[13]
          detalhe << pagamento.formata_valor_iof                            # 193-205 Valor IOF                    9[13]
          detalhe << pagamento.formata_valor_abatimento                     # 206-218 Valor abatimento              9[13]
          detalhe << pagamento.identificacao_sacado                         # 219-220 Tipo inscrição pagador        9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # 221-234 Documento pagador             9[14]
          detalhe << pagamento.nome_sacado.format_size(40)                  # 235-274 Nome pagador                 X[40]
          detalhe << pagamento.endereco_sacado.format_size(40)              # 275-314 Endereço pagador             X[40]
          detalhe << ''.rjust(12, ' ')                                      # 315-326 1a mensagem (brancos)         X[12]
          detalhe << pagamento.cep_sacado.to_s[0..4]                        # 327-331 CEP (5 dígitos)               9[05]
          detalhe << pagamento.cep_sacado.to_s[5..7]                        # 332-334 Sufixo CEP (3 dígitos)        9[03]
          detalhe << ''.rjust(60, ' ')                                      # 335-394 Sacador/Avalista (brancos)    X[60]
          detalhe << sequencial.to_s.rjust(6, '0')                          # 395-400 Nº sequencial registro        9[06]
          detalhe
        end

        def prazo_instrucao(pagamento)
          return "03" unless %w[09 34 35].include?(
            pagamento.cod_primeira_instrucao
          )

          pagamento.dias_protesto.rjust(2, '0')
        end

        def monta_detalhe_multa(pagamento, sequencial)
          detalhe = '2'
          detalhe += pagamento.codigo_multa
          detalhe << pagamento.data_vencimento.strftime('%d%m%Y')
          detalhe << pagamento.formata_percentual_multa(13)
          detalhe << ''.rjust(371, ' ')
          detalhe << sequencial.to_s.rjust(6, '0')
          detalhe
        end
      end
    end
  end
end
