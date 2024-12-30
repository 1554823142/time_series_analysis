# renderer.py
from IPython.display import display, HTML

def render_html_widget(html_content: str):
    display(HTML(html_content))