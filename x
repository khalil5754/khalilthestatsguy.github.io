# app.py

import streamlit as st
import pandas as pd
import openai
import os

df = pd.DataFrame(data)
df['Liquidity Variable'] = df['Liquidity Variable'].str.lower()

# Initialize session state for conversation
if 'conversation_history' not in st.session_state:
    st.session_state.conversation_history = []

def main():
    st.title("💼 Corporate Treasury Chatbot")

    # Display conversation history
    for message in st.session_state.conversation_history:
        if message['role'] == 'user':
            st.markdown(f"**You:** {message['content']}")
        else:
            st.markdown(f"**Assistant:** {message['content']}")

    # User input
    user_input = st.text_input("Ask a question about treasury operations...")

    if user_input:
        # Append user message to conversation history
        st.session_state.conversation_history.append({"role": "user", "content": user_input})

        # Process the input and get assistant's response
        assistant_response = process_user_input(user_input)

        # Append assistant's response to conversation history
        st.session_state.conversation_history.append({"role": "assistant", "content": assistant_response})

        # Display the assistant's response
        st.markdown(f"**Assistant:** {assistant_response}")

def process_user_input(user_input):
    conversation = st.session_state.conversation_history

    # Attempt to extract information from the entire conversation
    extracted_info = extract_information_from_conversation(conversation)

    # Check for missing information
    missing_info = get_missing_information(extracted_info)

    if missing_info:
        # Ask for missing information
        question = generate_followup_question(missing_info)
        return question
    else:
        # All required information is present, perform the query
        result = query_dataframe(extracted_info)
        if result.empty:
            return "I'm sorry, I couldn't find any data matching your query."
        else:
            # Display the result as a table
            st.table(result)
            return "Here are the results based on your query."

def extract_information_from_conversation(conversation):
    info = {
        'Liquidity Variable': None,
        'Time to Maturity': None,
        'Region': None,
        'FI_NonFI': None,
        'IG_NonIG': None
    }

    # Process each message in the conversation
    for message in conversation:
        if message['role'] == 'user':
            user_info = extract_information(message['content'])
            for key in info:
                if not info[key] and user_info[key]:
                    info[key] = user_info[key]

    return info

def extract_information(user_input):
    info = {
        'Liquidity Variable': None,
        'Time to Maturity': None,
        'Region': None,
        'FI_NonFI': None,
        'IG_NonIG': None
    }

    user_input_lower = user_input.lower()

    # Liquidity Variables mapping
    liquidity_variables = {
        'uk government bonds': 'uk government bonds',
        'german government bonds': 'german government bonds',
        'france government bonds': 'france government bonds',
        'australian government bonds': 'au government bonds',
        'au government bonds': 'au government bonds',
        'japanese government bonds': 'jp government bonds',
        'japan government bonds': 'jp government bonds',
        'jp government bonds': 'jp government bonds',
        'hong kong government bonds': 'hk government bonds',
        'hong kong bonds': 'hk government bonds',
        'hk government bonds': 'hk government bonds',
        'singapore government bonds': 'sg government bonds',
        'singapore bonds': 'sg government bonds',
        'sg government bonds': 'sg government bonds',
        'ontario bonds': 'canadian provinces - ontario',
        'alberta bonds': 'canadian provinces - alberta',
        'quebec bonds': 'canadian provinces - quebec',
        'british columbia bonds': 'canadian provinces - british columbia',
        # Add other mappings as necessary
    }

    # Time to Maturity mapping
    ttm_mapping = {
        'less than 1 year': '< 1 year',
        'under 1 year': '< 1 year',
        '< 1 year': '< 1 year',
        '1 year': '< 1 year',
        'between 1 and 5 years': '1 - 5 years',
        '1 - 5 years': '1 - 5 years',
        '1 to 5 years': '1 - 5 years',
        '2 years': '1 - 5 years',
        '3 years': '1 - 5 years',
        '4 years': '1 - 5 years',
        '5 years': '1 - 5 years',
        'more than 5 years': '> 5 years',
        '> 5 years': '> 5 years',
        'over 5 years': '> 5 years',
        '6 years': '> 5 years',
        # Add other mappings as necessary
    }

    # Regions
    regions = ['apac', 'canada', 'cuso', 'default', 'europe']

    # Extract Liquidity Variable
    for key, value in liquidity_variables.items():
        if key in user_input_lower:
            info['Liquidity Variable'] = value
            break
    else:
        # Check for 'government bonds - other'
        if 'government bonds' in user_input_lower:
            info['Liquidity Variable'] = 'government bonds - other'

            # Extract IG_NonIG
            if 'investment grade' in user_input_lower or 'ig' in user_input_lower:
                info['IG_NonIG'] = 'IG'
            elif 'non-investment grade' in user_input_lower or 'non-ig' in user_input_lower:
                info['IG_NonIG'] = 'NonIG'

            # Extract FI_NonFI
            if 'fi' in user_input_lower:
                info['FI_NonFI'] = 'FI'
            elif 'non-fi' in user_input_lower:
                info['FI_NonFI'] = 'NonFI'

    # Extract Time to Maturity
    for key, value in ttm_mapping.items():
        if key in user_input_lower:
            info['Time to Maturity'] = value
            break

    # Extract Region
    for region in regions:
        if region in user_input_lower:
            info['Region'] = region.upper()
            break

    return info

def get_missing_information(extracted_info):
    required_fields = []

    # Liquidity Variable is mandatory
    if not extracted_info['Liquidity Variable']:
        required_fields.append('Liquidity Variable')

    # Time to Maturity is mandatory
    if not extracted_info['Time to Maturity']:
        required_fields.append('Time to Maturity')

    # Region is mandatory
    if not extracted_info['Region']:
        required_fields.append('Region')

    # For 'government bonds - other', FI_NonFI and IG_NonIG are required
    if extracted_info['Liquidity Variable'] == 'government bonds - other':
        if not extracted_info['FI_NonFI']:
            required_fields.append('FI_NonFI')
        if not extracted_info['IG_NonIG']:
            required_fields.append('IG_NonIG')
    else:
        # For specific Liquidity Variables, FI_NonFI and IG_NonIG are not required
        extracted_info['FI_NonFI'] = None
        extracted_info['IG_NonIG'] = None

    if required_fields:
        return required_fields
    else:
        return None

def generate_followup_question(missing_info):
    questions = {
        'Liquidity Variable': "Could you please specify the Liquidity Variable?",
        'Time to Maturity': "What is the Time to Maturity? Possible options are: '< 1 year', '1 - 5 years', '> 5 years'.",
        'Region': "What is the Region? Possible regions are: APAC, Canada, CUSO, DEFAULT, or EUROPE.",
        'FI_NonFI': "Is it FI or NonFI?",
        'IG_NonIG': "Is it Investment Grade (IG) or Non-Investment Grade (NonIG)?"
    }

    question_list = [questions[field] for field in missing_info]
    return ' '.join(question_list)

def query_dataframe(extracted_info):
    query_df = df.copy()

    # Apply filters based on extracted information
    if extracted_info['Liquidity Variable']:
        query_df = query_df[query_df['Liquidity Variable'] == extracted_info['Liquidity Variable']]

    if extracted_info['Time to Maturity']:
        query_df = query_df[query_df['Time to Maturity'] == extracted_info['Time to Maturity']]

    if extracted_info['Region']:
        query_df = query_df[query_df['Region'].str.upper() == extracted_info['Region']]

    if extracted_info['FI_NonFI'] is not None:
        query_df = query_df[query_df['FI_NonFI'] == extracted_info['FI_NonFI']]

    if extracted_info['IG_NonIG'] is not None:
        query_df = query_df[query_df['IG_NonIG'] == extracted_info['IG_NonIG']]

    return query_df

if __name__ == "__main__":
    main()
