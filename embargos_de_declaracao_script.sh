# TODO: the values should be populated in the correct font and size
# TODO: infring_text should be populated in bold mode

VENV_PATH="embargos_de_declaracao_env"

if [ ! -d "$VENV_PATH" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_PATH"
    source "$VENV_PATH/bin/activate"
    pip install python-docx
    deactivate
fi

read -p "Enter client name: " client
read -p "Enter process number: " process_number
read -p "Does this have infringing effect? (yes/no): " has_infringing_effect

client_upper=$(echo "$client" | tr '[:lower:]' '[:upper:]')

if [[ "$has_infringing_effect" =~ ^[yY](es)?$ ]]; then
    infringing_text="Embargos de Declaração com Efeitos Infringentes"
else
    infringing_text="Embargos de Declaração"
fi

source "$VENV_PATH/bin/activate"
python3 -c "
from docx import Document
doc = Document('modelo_embargos_de_declaracao.docx')
for paragraph in doc.paragraphs:
    if '{{TEMPLATE_CLIENT}}' in paragraph.text:
        paragraph.text = paragraph.text.replace('{{TEMPLATE_CLIENT}}', '$client_upper')
    if '{{TEMPLATE_PROCESS_NUMBER}}' in paragraph.text:
        paragraph.text = paragraph.text.replace('{{TEMPLATE_PROCESS_NUMBER}}', '$process_number')
    if '{{TEMPLATE_INFRINGING_EFFECT}}' in paragraph.text:
        for run in paragraph.runs:
            if '{{TEMPLATE_INFRINGING_EFFECT}}' in run.text:
                text = run.text.split('{{TEMPLATE_INFRINGING_EFFECT}}')
                run.text = text[0]
                new_run = paragraph.add_run('$infringing_text')
                new_run.bold = True
                if len(text) > 1:
                    paragraph.add_run(text[1])
doc.save('output.docx')
"
deactivate

echo "Document generated as output.docx"