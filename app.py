import streamlit as st
from pathlib import Path

st.set_page_config(
    page_title="Nassau Candy Analysis",
    page_icon="🍬",
    layout="wide"
)

st.title("🍬 Nassau Candy Project Analysis")
st.write("Sales analysis, project summary and dashboard.")

files = {
    "Dashboard": "Dashboard_nassau_candy.pdf",
    "Executive Summary": "Executive__Summary.pdf",
    "Project Workflow": "project_Workflow.pdf",
}

for title, filename in files.items():
    st.subheader(title)
    path = Path(filename)

    if path.exists():
        st.download_button(
            label=f"View / Download {title} PDF",
            data=path.read_bytes(),
            file_name=filename,
            mime="application/pdf",
            key=filename
        )
    else:
        st.warning(f"{filename} file not found in repository.")
