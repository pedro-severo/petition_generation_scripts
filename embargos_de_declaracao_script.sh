# TODO: the values should be populated in the correct font and size

VENV_PATH="embargos_de_declaracao_env"

if [ ! -d "$VENV_PATH" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_PATH"
    source "$VENV_PATH/bin/activate"
    pip install python-docx
    deactivate
fi

read -p "Enter client name: " client
read -p "Enter 'embargante' name: " embargante
read -p "Enter process number: " process_number

client_upper=$(echo "$client" | tr '[:lower:]' '[:upper:]')
embargante_upper=$(echo "$embargante" | tr '[:lower:]' '[:upper:]')

source "$VENV_PATH/bin/activate"
python3 -c "
from docx import Document
from docx.shared import Pt

doc = Document('modelo_embargos_de_declaracao.docx')

for paragraph in doc.paragraphs:
    for run in paragraph.runs:
        if '{{TEMPLATE_PROCESS_NUMBER}}' in run.text:
            run.text = run.text.replace('{{TEMPLATE_PROCESS_NUMBER}}', '$process_number')
        if '{{TEMPLATE_CLIENT}}' in run.text:
            run.text = run.text.replace('{{TEMPLATE_CLIENT}}', '$client_upper')
        if '{{TEMPLATE_EMBARGANTE}}' in run.text:
            run.text = run.text.replace('{{TEMPLATE_EMBARGANTE}}', '$embargante_upper')

doc.save('output.docx')
"
deactivate

echo "Document generated as output.docx"