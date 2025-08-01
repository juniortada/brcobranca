# frozen_string_literal: true

require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      class Kanastra < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth # Extendendo parseline

        # Load lines
        def self.load_lines(file, options = {})
          default_options = { except: [1] } # por padrao ignora a primeira linha que é header
          options = default_options.merge!(options)
          super(file, options)
        end

        fixed_width_layout do |parse|
          # Layout Kanastra CNAB400 Retorno - Campos iniciais
          parse.field :codigo_registro, 0..0        # 001-001 Identificação do registro
          parse.field :tipo_inscricao, 1..2         # 002-003 Tipo inscrição empresa (01=CPF, 02=CNPJ)
          parse.field :documento_cedente, 3..16     # 004-017 CNPJ/CPF
          parse.field :brancos, 17..20              # 018-020 Brancos
          
          # Identificação da empresa no banco (21-37)
          parse.field :zero_fixo, 21..21            # 021-021 Zero fixo
          parse.field :carteira, 22..24             # 022-024 Código da carteira
          parse.field :agencia, 25..29              # 025-029 Agência (sem DV)
          parse.field :conta_corrente, 30..36       # 030-036 Conta corrente (sem DV)
          parse.field :digito_conta, 37..37         # 037-037 Dígito da conta

          # :brancos, 29..36 #complemento de registro
          # :uso_da_empresa, 37..61 #identificacao do titulo na empresa

          # :nosso_numero,62..69 # identificacao do titulo no banco
          parse.field :nosso_numero, 62..69

          # :brancos, 70..81 #complemento do registro

          # :carteira, 82..84 #numero da carteira
          parse.field :carteira_variacao, 82..84

          # :nosso_numero, 85..92 #identificacao do titulo no banco (novamente?)
          # :dac_nosso_numero, 93..93 #dac nosso numero
          # :brancos, 94..106 #complemento do registro

          # :carteira, 107..107 #código da carteira
          parse.field :brancos, 83..104            # 083-104 Brancos
          parse.field :indicador_rateio, 105..105   # 105-105 Indicador rateio crédito
          parse.field :pagamento_parcial, 106..107 # 106-107 Pagamento parcial
          parse.field :brancos_108, 108..108       # 108-108 Brancos

          parse.field :codigo_ocorrencia, 109..110 # 109-110 Código ocorrência
          parse.field :data_ocorrencia, 111..116   # 111-116 Data ocorrência (DDMMAA)
          parse.field :numero_documento, 117..126  # 117-126 Número documento
          parse.field :brancos_127_146, 127..146   # 127-146 Brancos
          parse.field :data_vencimento, 147..152   # 147-152 Data vencimento (DDMMAA)
          parse.field :valor_titulo, 153..165      # 153-165 Valor título (sem vírgula)
          parse.field :banco_cobrador, 166..168    # 166-168 Código banco cobrador
          parse.field :agencia_cobradora, 169..173 # 169-173 Agência cobradora
          parse.field :brancos_174_175, 174..175   # 174-175 Espécie título (brancos)

          parse.field :valor_tarifa, 176..188      # 176-188 Valor tarifa
          parse.field :valor_outras_despesas, 189..201 # 189-201 Outras despesas
          parse.field :valor_juros_atraso, 202..214 # 202-214 Juros operação em atraso
          parse.field :valor_iof, 215..227         # 215-227 IOF devido
          parse.field :valor_abatimento, 228..240  # 228-240 Abatimento concedido
          parse.field :valor_desconto, 241..253    # 241-253 Desconto concedido
          parse.field :valor_pago, 254..266        # 254-266 Valor pago
          parse.field :valor_juros_mora, 267..279  # 267-279 Juros de mora
          parse.field :valor_outros_creditos, 280..292 # 280-292 Outros créditos
          parse.field :brancos_293_295, 293..295   # 293-295 Motivo ocorrência 25 (brancos)
          parse.field :data_credito, 296..301      # 296-301 Data crédito (DDMMAA)
          parse.field :brancos_302_318, 302..318   # 302-318 Brancos
          parse.field :motivos_rejeicao, 319..328  # 319-328 Motivos rejeição

          # :instr_cancelada, 301..304 # codigo da instrucao cancelada
          # :brancos , 305..310 # complemento de registro
          # :zeros, 311..323 #complemento de registro
          # :nome_do_sacado, 324..353, #nome do sacado
          # :brancos , 354..376 # complemento de registro
          # :erros_msg, 377..384 #registros rejeitados ou laegacao do sacado ou registro de mensagem informativa
          # :brancos, 385..391 #complemento de registro
          # :cod_de_liquidacao, 392..393 #meio pelo qual o título foi liquidado

          parse.field :brancos_329_394, 329..394   # 329-394 Brancos
          parse.field :sequencial, 395..400        # 395-400 Número sequencial
        end
      end
    end
  end
end
