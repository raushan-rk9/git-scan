--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.3
-- Dumped by pg_dump version 12.2

-- Started on 2020-07-22 13:08:27 PDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- TOC entry 197 (class 1259 OID 1314376)
-- Name: action_items; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.action_items (
    id bigint NOT NULL,
    actionitemid integer,
    description text,
    openedby character varying,
    assignedto character varying,
    status character varying,
    note text,
    item_id bigint,
    project_id bigint,
    review_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint
);


ALTER TABLE public.action_items OWNER TO admin;

--
-- TOC entry 196 (class 1259 OID 1314374)
-- Name: action_items_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.action_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.action_items_id_seq OWNER TO admin;

--
-- TOC entry 3048 (class 0 OID 0)
-- Dependencies: 196
-- Name: action_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.action_items_id_seq OWNED BY public.action_items.id;


--
-- TOC entry 209 (class 1259 OID 1314498)
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.active_storage_attachments OWNER TO admin;

--
-- TOC entry 208 (class 1259 OID 1314496)
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_storage_attachments_id_seq OWNER TO admin;

--
-- TOC entry 3049 (class 0 OID 0)
-- Dependencies: 208
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- TOC entry 207 (class 1259 OID 1314486)
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.active_storage_blobs OWNER TO admin;

--
-- TOC entry 206 (class 1259 OID 1314484)
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_storage_blobs_id_seq OWNER TO admin;

--
-- TOC entry 3050 (class 0 OID 0)
-- Dependencies: 206
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- TOC entry 174 (class 1259 OID 1314127)
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO admin;

--
-- TOC entry 236 (class 1259 OID 1314776)
-- Name: archives; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.archives (
    id bigint NOT NULL,
    name character varying NOT NULL,
    full_id character varying NOT NULL,
    description character varying NOT NULL,
    revision character varying NOT NULL,
    version character varying NOT NULL,
    archived_at timestamp without time zone NOT NULL,
    organization character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id bigint,
    pact_version character varying,
    archive_type character varying,
    item_id integer,
    archive_project_id integer,
    archive_item_id integer,
    archive_item_ids character varying
);


ALTER TABLE public.archives OWNER TO admin;

--
-- TOC entry 235 (class 1259 OID 1314774)
-- Name: archives_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.archives_id_seq OWNER TO admin;

--
-- TOC entry 3051 (class 0 OID 0)
-- Dependencies: 235
-- Name: archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.archives_id_seq OWNED BY public.archives.id;


--
-- TOC entry 220 (class 1259 OID 1314612)
-- Name: change_sessions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.change_sessions (
    id bigint NOT NULL,
    session_id integer NOT NULL,
    data_change_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying
);


ALTER TABLE public.change_sessions OWNER TO admin;

--
-- TOC entry 219 (class 1259 OID 1314610)
-- Name: change_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.change_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.change_sessions_id_seq OWNER TO admin;

--
-- TOC entry 3052 (class 0 OID 0)
-- Dependencies: 219
-- Name: change_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.change_sessions_id_seq OWNED BY public.change_sessions.id;


--
-- TOC entry 195 (class 1259 OID 1314353)
-- Name: checklist_items; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.checklist_items (
    id bigint NOT NULL,
    clitemid integer,
    review_id bigint,
    document_id bigint,
    description text,
    note text,
    reference character varying,
    minimumdal character varying,
    supplements text,
    status character varying,
    evaluator character varying,
    evaluation_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    assigned boolean,
    user_id bigint,
    version character varying
);


ALTER TABLE public.checklist_items OWNER TO admin;

--
-- TOC entry 194 (class 1259 OID 1314351)
-- Name: checklist_items_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.checklist_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_items_id_seq OWNER TO admin;

--
-- TOC entry 3053 (class 0 OID 0)
-- Dependencies: 194
-- Name: checklist_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.checklist_items_id_seq OWNED BY public.checklist_items.id;


--
-- TOC entry 246 (class 1259 OID 1314872)
-- Name: code_checkmark_hits; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.code_checkmark_hits (
    id bigint NOT NULL,
    code_checkmark_id bigint NOT NULL,
    hit_at timestamp(6) without time zone,
    organization character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.code_checkmark_hits OWNER TO admin;

--
-- TOC entry 245 (class 1259 OID 1314870)
-- Name: code_checkmark_hits_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.code_checkmark_hits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.code_checkmark_hits_id_seq OWNER TO admin;

--
-- TOC entry 3054 (class 0 OID 0)
-- Dependencies: 245
-- Name: code_checkmark_hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.code_checkmark_hits_id_seq OWNED BY public.code_checkmark_hits.id;


--
-- TOC entry 244 (class 1259 OID 1314853)
-- Name: code_checkmarks; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.code_checkmarks (
    id bigint NOT NULL,
    checkmark_id integer NOT NULL,
    source_code_id bigint NOT NULL,
    filename character varying NOT NULL,
    line_number integer NOT NULL,
    code_statement character varying,
    organization character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.code_checkmarks OWNER TO admin;

--
-- TOC entry 243 (class 1259 OID 1314851)
-- Name: code_checkmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.code_checkmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.code_checkmarks_id_seq OWNER TO admin;

--
-- TOC entry 3055 (class 0 OID 0)
-- Dependencies: 243
-- Name: code_checkmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.code_checkmarks_id_seq OWNED BY public.code_checkmarks.id;


--
-- TOC entry 248 (class 1259 OID 1314890)
-- Name: code_conditional_blocks; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.code_conditional_blocks (
    id bigint NOT NULL,
    source_code_id bigint NOT NULL,
    filename character varying NOT NULL,
    start_line_number integer NOT NULL,
    end_line_number integer NOT NULL,
    condition character varying,
    "offset" boolean,
    organization character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.code_conditional_blocks OWNER TO admin;

--
-- TOC entry 247 (class 1259 OID 1314888)
-- Name: code_conditional_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.code_conditional_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.code_conditional_blocks_id_seq OWNER TO admin;

--
-- TOC entry 3056 (class 0 OID 0)
-- Dependencies: 247
-- Name: code_conditional_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.code_conditional_blocks_id_seq OWNED BY public.code_conditional_blocks.id;


--
-- TOC entry 242 (class 1259 OID 1314840)
-- Name: constants; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.constants (
    id bigint NOT NULL,
    name character varying,
    label character varying,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.constants OWNER TO admin;

--
-- TOC entry 241 (class 1259 OID 1314838)
-- Name: constants_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.constants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.constants_id_seq OWNER TO admin;

--
-- TOC entry 3057 (class 0 OID 0)
-- Dependencies: 241
-- Name: constants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.constants_id_seq OWNED BY public.constants.id;


--
-- TOC entry 217 (class 1259 OID 1314598)
-- Name: data_changes; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.data_changes (
    id bigint NOT NULL,
    changed_by character varying NOT NULL,
    table_name character varying NOT NULL,
    table_id integer NOT NULL,
    action character varying NOT NULL,
    performed_at timestamp without time zone NOT NULL,
    record_attributes json,
    rolled_back boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    change_type character varying
);


ALTER TABLE public.data_changes OWNER TO admin;

--
-- TOC entry 216 (class 1259 OID 1314596)
-- Name: data_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.data_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.data_changes_id_seq OWNER TO admin;

--
-- TOC entry 3058 (class 0 OID 0)
-- Dependencies: 216
-- Name: data_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.data_changes_id_seq OWNED BY public.data_changes.id;


--
-- TOC entry 211 (class 1259 OID 1314511)
-- Name: document_attachments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.document_attachments (
    id bigint NOT NULL,
    document_id bigint,
    item_id bigint,
    project_id bigint,
    "user" character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    upload_date timestamp without time zone
);


ALTER TABLE public.document_attachments OWNER TO admin;

--
-- TOC entry 210 (class 1259 OID 1314509)
-- Name: document_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.document_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_attachments_id_seq OWNER TO admin;

--
-- TOC entry 3059 (class 0 OID 0)
-- Dependencies: 210
-- Name: document_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.document_attachments_id_seq OWNED BY public.document_attachments.id;


--
-- TOC entry 193 (class 1259 OID 1314324)
-- Name: document_comments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.document_comments (
    id bigint NOT NULL,
    commentid integer,
    comment text,
    docrevision character varying,
    datemodified timestamp without time zone,
    status character varying,
    requestedby character varying,
    assignedto character varying,
    item_id bigint,
    project_id bigint,
    document_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    draft_revision character varying
);


ALTER TABLE public.document_comments OWNER TO admin;

--
-- TOC entry 192 (class 1259 OID 1314322)
-- Name: document_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.document_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_comments_id_seq OWNER TO admin;

--
-- TOC entry 3060 (class 0 OID 0)
-- Dependencies: 192
-- Name: document_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.document_comments_id_seq OWNED BY public.document_comments.id;


--
-- TOC entry 256 (class 1259 OID 1314966)
-- Name: document_types; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.document_types (
    id bigint NOT NULL,
    document_code character varying,
    description character varying,
    item_types character varying,
    dal_levels character varying,
    control_category character varying,
    organization character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.document_types OWNER TO admin;

--
-- TOC entry 255 (class 1259 OID 1314964)
-- Name: document_types_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.document_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_types_id_seq OWNER TO admin;

--
-- TOC entry 3061 (class 0 OID 0)
-- Dependencies: 255
-- Name: document_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.document_types_id_seq OWNED BY public.document_types.id;


--
-- TOC entry 189 (class 1259 OID 1314267)
-- Name: documents; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    document_id integer,
    docid character varying,
    name text,
    category character varying,
    revision character varying,
    draft_revision character varying,
    document_type character varying,
    review_status character varying,
    revdate date,
    version integer,
    item_id bigint,
    project_id bigint,
    review_id bigint,
    parent_id bigint,
    file_path character varying,
    file_type character varying,
    doccomment_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    upload_date timestamp without time zone
);


ALTER TABLE public.documents OWNER TO admin;

--
-- TOC entry 188 (class 1259 OID 1314265)
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.documents_id_seq OWNER TO admin;

--
-- TOC entry 3062 (class 0 OID 0)
-- Dependencies: 188
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- TOC entry 225 (class 1259 OID 1314657)
-- Name: github_accesses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.github_accesses (
    id bigint NOT NULL,
    username text,
    password text,
    token text,
    user_id bigint,
    last_accessed_repository text,
    last_accessed_branch text,
    last_accessed_folder text,
    last_accessed_file text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying
);


ALTER TABLE public.github_accesses OWNER TO admin;

--
-- TOC entry 224 (class 1259 OID 1314655)
-- Name: github_accesses_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.github_accesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.github_accesses_id_seq OWNER TO admin;

--
-- TOC entry 3063 (class 0 OID 0)
-- Dependencies: 224
-- Name: github_accesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.github_accesses_id_seq OWNED BY public.github_accesses.id;


--
-- TOC entry 238 (class 1259 OID 1314804)
-- Name: gitlab_accesses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.gitlab_accesses (
    id bigint NOT NULL,
    username text,
    password text,
    token text,
    user_id bigint,
    last_accessed_repository text,
    last_accessed_branch text,
    last_accessed_folder text,
    last_accessed_file text,
    url character varying,
    organization character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.gitlab_accesses OWNER TO admin;

--
-- TOC entry 237 (class 1259 OID 1314802)
-- Name: gitlab_accesses_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.gitlab_accesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gitlab_accesses_id_seq OWNER TO admin;

--
-- TOC entry 3064 (class 0 OID 0)
-- Dependencies: 237
-- Name: gitlab_accesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.gitlab_accesses_id_seq OWNED BY public.gitlab_accesses.id;


--
-- TOC entry 184 (class 1259 OID 1314212)
-- Name: high_level_requirements; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.high_level_requirements (
    id bigint NOT NULL,
    reqid integer NOT NULL,
    full_id text,
    description text,
    category text,
    verification_method text,
    safety boolean,
    robustness boolean,
    derived boolean,
    testmethod character varying,
    version integer,
    item_id bigint,
    project_id bigint,
    system_requirement_associations text,
    derived_justification text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    high_level_requirement_associations character varying,
    soft_delete boolean,
    document_id bigint,
    model_file_id bigint
);


ALTER TABLE public.high_level_requirements OWNER TO admin;

--
-- TOC entry 183 (class 1259 OID 1314210)
-- Name: high_level_requirements_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.high_level_requirements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.high_level_requirements_id_seq OWNER TO admin;

--
-- TOC entry 3065 (class 0 OID 0)
-- Dependencies: 183
-- Name: high_level_requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.high_level_requirements_id_seq OWNED BY public.high_level_requirements.id;


--
-- TOC entry 257 (class 1259 OID 1314977)
-- Name: hlr_hlrs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.hlr_hlrs (
    high_level_requirement_id integer,
    referenced_high_level_requirement_id integer
);


ALTER TABLE public.hlr_hlrs OWNER TO admin;

--
-- TOC entry 202 (class 1259 OID 1314449)
-- Name: hlr_llrs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.hlr_llrs (
    high_level_requirement_id integer,
    low_level_requirement_id integer
);


ALTER TABLE public.hlr_llrs OWNER TO admin;

--
-- TOC entry 263 (class 1259 OID 1315060)
-- Name: hlr_mfs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.hlr_mfs (
    high_level_requirement_id bigint NOT NULL,
    model_file_id bigint NOT NULL
);


ALTER TABLE public.hlr_mfs OWNER TO admin;

--
-- TOC entry 232 (class 1259 OID 1314718)
-- Name: hlr_scs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.hlr_scs (
    high_level_requirement_id integer,
    source_code_id integer
);


ALTER TABLE public.hlr_scs OWNER TO admin;

--
-- TOC entry 205 (class 1259 OID 1314479)
-- Name: hlr_tcs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.hlr_tcs (
    high_level_requirement_id integer,
    test_case_id integer
);


ALTER TABLE public.hlr_tcs OWNER TO admin;

--
-- TOC entry 251 (class 1259 OID 1314938)
-- Name: hlr_tps; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.hlr_tps (
    high_level_requirement_id integer,
    test_procedure_id integer
);


ALTER TABLE public.hlr_tps OWNER TO admin;

--
-- TOC entry 182 (class 1259 OID 1314190)
-- Name: items; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.items (
    id bigint NOT NULL,
    name character varying NOT NULL,
    itemtype character varying,
    identifier character varying,
    level character varying,
    project_id bigint,
    hlr_count integer DEFAULT 0,
    llr_count integer DEFAULT 0,
    review_count integer DEFAULT 0,
    tc_count integer DEFAULT 0,
    sc_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    high_level_requirements_prefix character varying,
    low_level_requirements_prefix character varying,
    source_code_prefix character varying,
    test_case_prefix character varying,
    test_procedure_prefix character varying,
    tp_count integer,
    model_file_prefix character varying
);


ALTER TABLE public.items OWNER TO admin;

--
-- TOC entry 181 (class 1259 OID 1314188)
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.items_id_seq OWNER TO admin;

--
-- TOC entry 3066 (class 0 OID 0)
-- Dependencies: 181
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- TOC entry 259 (class 1259 OID 1314984)
-- Name: licensees; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.licensees (
    id bigint NOT NULL,
    identifier character varying,
    name character varying,
    description text,
    setup_date date,
    license_date date,
    license_type character varying,
    renewal_date date,
    administrator character varying,
    contact_information text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_emails character varying
);


ALTER TABLE public.licensees OWNER TO admin;

--
-- TOC entry 258 (class 1259 OID 1314982)
-- Name: licensees_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.licensees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.licensees_id_seq OWNER TO admin;

--
-- TOC entry 3067 (class 0 OID 0)
-- Dependencies: 258
-- Name: licensees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.licensees_id_seq OWNED BY public.licensees.id;


--
-- TOC entry 264 (class 1259 OID 1315065)
-- Name: llr_mfs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.llr_mfs (
    low_level_requirement_id bigint NOT NULL,
    model_file_id bigint NOT NULL
);


ALTER TABLE public.llr_mfs OWNER TO admin;

--
-- TOC entry 223 (class 1259 OID 1314650)
-- Name: llr_scs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.llr_scs (
    low_level_requirement_id integer,
    source_code_id integer
);


ALTER TABLE public.llr_scs OWNER TO admin;

--
-- TOC entry 253 (class 1259 OID 1314953)
-- Name: llr_tcs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.llr_tcs (
    low_level_requirement_id integer,
    test_case_id integer
);


ALTER TABLE public.llr_tcs OWNER TO admin;

--
-- TOC entry 252 (class 1259 OID 1314943)
-- Name: llr_tps; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.llr_tps (
    low_level_requirement_id integer,
    test_procedure_id integer
);


ALTER TABLE public.llr_tps OWNER TO admin;

--
-- TOC entry 191 (class 1259 OID 1314299)
-- Name: low_level_requirements; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.low_level_requirements (
    id bigint NOT NULL,
    reqid integer,
    full_id text,
    description text,
    category text,
    verification_method text,
    safety boolean,
    derived boolean,
    version integer,
    item_id bigint,
    project_id bigint,
    high_level_requirement_associations text,
    derived_justification text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    soft_delete boolean,
    document_id bigint,
    model_file_id bigint
);


ALTER TABLE public.low_level_requirements OWNER TO admin;

--
-- TOC entry 190 (class 1259 OID 1314297)
-- Name: low_level_requirements_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.low_level_requirements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.low_level_requirements_id_seq OWNER TO admin;

--
-- TOC entry 3068 (class 0 OID 0)
-- Dependencies: 190
-- Name: low_level_requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.low_level_requirements_id_seq OWNED BY public.low_level_requirements.id;


--
-- TOC entry 261 (class 1259 OID 1315026)
-- Name: model_files; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.model_files (
    id bigint NOT NULL,
    model_id integer,
    full_id character varying,
    description text,
    file_path character varying,
    file_type character varying,
    url_type character varying,
    url_link character varying,
    url_description character varying,
    soft_delete boolean,
    derived boolean,
    derived_justification character varying,
    system_requirement_associations character varying,
    high_level_requirement_associations character varying,
    low_level_requirement_associations character varying,
    test_case_associations character varying,
    version integer,
    revision character varying,
    draft_version character varying,
    revision_date date,
    organization character varying,
    project_id bigint,
    item_id bigint,
    archive_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    upload_date timestamp without time zone
);


ALTER TABLE public.model_files OWNER TO admin;

--
-- TOC entry 260 (class 1259 OID 1315024)
-- Name: model_files_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.model_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.model_files_id_seq OWNER TO admin;

--
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 260
-- Name: model_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.model_files_id_seq OWNED BY public.model_files.id;


--
-- TOC entry 215 (class 1259 OID 1314569)
-- Name: problem_report_attachments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.problem_report_attachments (
    id bigint NOT NULL,
    problem_report_id bigint,
    item_id bigint,
    project_id bigint,
    link_type character varying,
    link_description character varying,
    link_link character varying,
    "user" character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    upload_date timestamp without time zone
);


ALTER TABLE public.problem_report_attachments OWNER TO admin;

--
-- TOC entry 214 (class 1259 OID 1314567)
-- Name: problem_report_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.problem_report_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.problem_report_attachments_id_seq OWNER TO admin;

--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 214
-- Name: problem_report_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.problem_report_attachments_id_seq OWNED BY public.problem_report_attachments.id;


--
-- TOC entry 201 (class 1259 OID 1314428)
-- Name: problem_report_histories; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.problem_report_histories (
    id bigint NOT NULL,
    action text,
    modifiedby character varying,
    status character varying,
    severity_type character varying,
    datemodified timestamp without time zone,
    project_id bigint,
    problem_report_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint
);


ALTER TABLE public.problem_report_histories OWNER TO admin;

--
-- TOC entry 200 (class 1259 OID 1314426)
-- Name: problem_report_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.problem_report_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.problem_report_histories_id_seq OWNER TO admin;

--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 200
-- Name: problem_report_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.problem_report_histories_id_seq OWNED BY public.problem_report_histories.id;


--
-- TOC entry 199 (class 1259 OID 1314405)
-- Name: problem_reports; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.problem_reports (
    id bigint NOT NULL,
    project_id bigint,
    item_id bigint,
    prid integer,
    dateopened timestamp without time zone,
    status character varying,
    openedby character varying,
    title character varying,
    product character varying,
    criticality character varying,
    source character varying,
    discipline_assigned character varying,
    assignedto character varying,
    target_date timestamp without time zone,
    close_date timestamp without time zone,
    description text,
    problemfoundin character varying,
    correctiveaction text,
    fixed_in character varying,
    verification character varying,
    feedback text,
    notes text,
    meeting_id character varying,
    safetyrelated boolean,
    datemodified timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint
);


ALTER TABLE public.problem_reports OWNER TO admin;

--
-- TOC entry 198 (class 1259 OID 1314403)
-- Name: problem_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.problem_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.problem_reports_id_seq OWNER TO admin;

--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 198
-- Name: problem_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.problem_reports_id_seq OWNED BY public.problem_reports.id;


--
-- TOC entry 234 (class 1259 OID 1314725)
-- Name: project_accesses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.project_accesses (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    project_id bigint NOT NULL,
    access character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying
);


ALTER TABLE public.project_accesses OWNER TO admin;

--
-- TOC entry 233 (class 1259 OID 1314723)
-- Name: project_accesses_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.project_accesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_accesses_id_seq OWNER TO admin;

--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 233
-- Name: project_accesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.project_accesses_id_seq OWNED BY public.project_accesses.id;


--
-- TOC entry 176 (class 1259 OID 1314137)
-- Name: projects; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    identifier character varying,
    name character varying,
    description character varying,
    access character varying,
    project_managers character varying,
    configuration_managers character varying,
    quality_assurance character varying,
    team_members character varying,
    airworthiness_reps character varying,
    sysreq_count integer DEFAULT 0,
    pr_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    system_requirements_prefix character varying,
    high_level_requirements_prefix character varying,
    low_level_requirements_prefix character varying,
    source_code_prefix character varying,
    test_case_prefix character varying,
    test_procedure_prefix character varying,
    model_file_prefix character varying
);


ALTER TABLE public.projects OWNER TO admin;

--
-- TOC entry 175 (class 1259 OID 1314135)
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO admin;

--
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 175
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- TOC entry 213 (class 1259 OID 1314540)
-- Name: review_attachments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.review_attachments (
    id bigint NOT NULL,
    review_id bigint,
    item_id bigint,
    project_id bigint,
    link_type character varying,
    link_description character varying,
    link_link character varying,
    "user" character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    attachment_type character varying,
    upload_date timestamp without time zone
);


ALTER TABLE public.review_attachments OWNER TO admin;

--
-- TOC entry 212 (class 1259 OID 1314538)
-- Name: review_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.review_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.review_attachments_id_seq OWNER TO admin;

--
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 212
-- Name: review_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.review_attachments_id_seq OWNED BY public.review_attachments.id;


--
-- TOC entry 187 (class 1259 OID 1314242)
-- Name: reviews; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.reviews (
    id bigint NOT NULL,
    reviewid integer,
    reviewtype character varying,
    title character varying,
    evaluators character varying,
    evaldate date,
    description character varying,
    version integer,
    item_id bigint,
    project_id bigint,
    clitem_count integer DEFAULT 0,
    ai_count integer DEFAULT 0,
    attendees text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    checklists_assigned boolean,
    sign_offs text,
    created_by character varying,
    problem_reports_addressed character varying,
    upload_date timestamp without time zone
);


ALTER TABLE public.reviews OWNER TO admin;

--
-- TOC entry 186 (class 1259 OID 1314240)
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reviews_id_seq OWNER TO admin;

--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 186
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- TOC entry 173 (class 1259 OID 1314119)
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO admin;

--
-- TOC entry 218 (class 1259 OID 1314608)
-- Name: session_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.session_id_seq OWNER TO admin;

--
-- TOC entry 222 (class 1259 OID 1314627)
-- Name: source_codes; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.source_codes (
    id bigint NOT NULL,
    codeid integer,
    full_id text,
    file_name text,
    module text,
    function text,
    derived boolean,
    derived_justification text,
    high_level_requirement_associations text,
    low_level_requirement_associations text,
    url_type text,
    url_description text,
    url_link text,
    version integer,
    item_id bigint,
    project_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    description text,
    soft_delete boolean,
    file_path character varying,
    content_type character varying,
    file_type character varying,
    revision character varying,
    draft_version character varying,
    revision_date date,
    upload_date timestamp without time zone
);


ALTER TABLE public.source_codes OWNER TO admin;

--
-- TOC entry 221 (class 1259 OID 1314625)
-- Name: source_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.source_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.source_codes_id_seq OWNER TO admin;

--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 221
-- Name: source_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.source_codes_id_seq OWNED BY public.source_codes.id;


--
-- TOC entry 185 (class 1259 OID 1314235)
-- Name: sysreq_hlrs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.sysreq_hlrs (
    system_requirement_id integer,
    high_level_requirement_id integer
);


ALTER TABLE public.sysreq_hlrs OWNER TO admin;

--
-- TOC entry 262 (class 1259 OID 1315055)
-- Name: sysreq_mfs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.sysreq_mfs (
    system_requirement_id bigint NOT NULL,
    model_file_id bigint NOT NULL
);


ALTER TABLE public.sysreq_mfs OWNER TO admin;

--
-- TOC entry 180 (class 1259 OID 1314171)
-- Name: system_requirements; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.system_requirements (
    id bigint NOT NULL,
    reqid integer NOT NULL,
    full_id text,
    description text,
    category text,
    verification_method text,
    source character varying,
    safety boolean,
    implementation character varying,
    version integer,
    derived boolean,
    derived_justification text,
    project_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    soft_delete boolean,
    document_id bigint,
    model_file_id bigint
);


ALTER TABLE public.system_requirements OWNER TO admin;

--
-- TOC entry 179 (class 1259 OID 1314169)
-- Name: system_requirements_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.system_requirements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_requirements_id_seq OWNER TO admin;

--
-- TOC entry 3078 (class 0 OID 0)
-- Dependencies: 179
-- Name: system_requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.system_requirements_id_seq OWNED BY public.system_requirements.id;


--
-- TOC entry 265 (class 1259 OID 1315070)
-- Name: tc_mfs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tc_mfs (
    test_case_id bigint NOT NULL,
    model_file_id bigint NOT NULL
);


ALTER TABLE public.tc_mfs OWNER TO admin;

--
-- TOC entry 254 (class 1259 OID 1314956)
-- Name: tcs_tps; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tcs_tps (
    test_case_id integer,
    test_procedure_id integer
);


ALTER TABLE public.tcs_tps OWNER TO admin;

--
-- TOC entry 231 (class 1259 OID 1314703)
-- Name: template_checklist_items; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.template_checklist_items (
    id bigint NOT NULL,
    clitemid integer,
    title text,
    description text,
    note text,
    template_checklist_id bigint,
    reference character varying,
    minimumdal character varying,
    supplements text,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    version character varying,
    source character varying
);


ALTER TABLE public.template_checklist_items OWNER TO admin;

--
-- TOC entry 230 (class 1259 OID 1314701)
-- Name: template_checklist_items_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.template_checklist_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.template_checklist_items_id_seq OWNER TO admin;

--
-- TOC entry 3079 (class 0 OID 0)
-- Dependencies: 230
-- Name: template_checklist_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.template_checklist_items_id_seq OWNED BY public.template_checklist_items.id;


--
-- TOC entry 229 (class 1259 OID 1314686)
-- Name: template_checklists; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.template_checklists (
    id bigint NOT NULL,
    clid integer,
    title text,
    description text,
    notes text,
    checklist_class text,
    checklist_type text,
    template_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    version character varying,
    source character varying,
    filename character varying,
    revision character varying,
    draft_revision character varying
);


ALTER TABLE public.template_checklists OWNER TO admin;

--
-- TOC entry 228 (class 1259 OID 1314684)
-- Name: template_checklists_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.template_checklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.template_checklists_id_seq OWNER TO admin;

--
-- TOC entry 3080 (class 0 OID 0)
-- Dependencies: 228
-- Name: template_checklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.template_checklists_id_seq OWNED BY public.template_checklists.id;


--
-- TOC entry 240 (class 1259 OID 1314823)
-- Name: template_documents; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.template_documents (
    id bigint NOT NULL,
    document_id integer,
    title text,
    description text,
    notes text,
    docid character varying,
    name text,
    category character varying,
    document_type character varying,
    document_class text,
    file_type character varying,
    template_id bigint,
    organization character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dal character varying,
    version character varying,
    source character varying,
    revision character varying,
    draft_revision character varying,
    upload_date timestamp without time zone
);


ALTER TABLE public.template_documents OWNER TO admin;

--
-- TOC entry 239 (class 1259 OID 1314821)
-- Name: template_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.template_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.template_documents_id_seq OWNER TO admin;

--
-- TOC entry 3081 (class 0 OID 0)
-- Dependencies: 239
-- Name: template_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.template_documents_id_seq OWNED BY public.template_documents.id;


--
-- TOC entry 227 (class 1259 OID 1314675)
-- Name: templates; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.templates (
    id bigint NOT NULL,
    tlid integer,
    title text,
    description text,
    notes text,
    template_class text,
    template_type text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    version character varying,
    source character varying
);


ALTER TABLE public.templates OWNER TO admin;

--
-- TOC entry 226 (class 1259 OID 1314673)
-- Name: templates_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.templates_id_seq OWNER TO admin;

--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 226
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.templates_id_seq OWNED BY public.templates.id;


--
-- TOC entry 204 (class 1259 OID 1314456)
-- Name: test_cases; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.test_cases (
    id bigint NOT NULL,
    caseid integer,
    full_id text,
    description text,
    procedure text,
    category character varying,
    robustness boolean,
    derived boolean,
    testmethod character varying,
    version integer,
    item_id bigint,
    project_id bigint,
    high_level_requirement_associations text,
    low_level_requirement_associations text,
    derived_justification text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization character varying,
    archive_id bigint,
    test_procedure_associations text,
    soft_delete boolean,
    document_id bigint,
    model_file_id bigint
);


ALTER TABLE public.test_cases OWNER TO admin;

--
-- TOC entry 203 (class 1259 OID 1314454)
-- Name: test_cases_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.test_cases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_cases_id_seq OWNER TO admin;

--
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 203
-- Name: test_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.test_cases_id_seq OWNED BY public.test_cases.id;


--
-- TOC entry 250 (class 1259 OID 1314908)
-- Name: test_procedures; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.test_procedures (
    id bigint NOT NULL,
    procedure_id integer,
    full_id text,
    file_name text,
    test_case_associations text,
    url_type text,
    url_description text,
    url_link text,
    version integer,
    organization character varying,
    item_id bigint,
    project_id bigint,
    archive_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    soft_delete boolean,
    document_id bigint,
    file_path character varying,
    content_type character varying,
    file_type character varying,
    revision character varying,
    draft_version character varying,
    revision_date date,
    upload_date timestamp without time zone
);


ALTER TABLE public.test_procedures OWNER TO admin;

--
-- TOC entry 249 (class 1259 OID 1314906)
-- Name: test_procedures_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.test_procedures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_procedures_id_seq OWNER TO admin;

--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 249
-- Name: test_procedures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.test_procedures_id_seq OWNED BY public.test_procedures.id;


--
-- TOC entry 178 (class 1259 OID 1314150)
-- Name: users; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    firstname character varying NOT NULL,
    lastname character varying NOT NULL,
    role text NOT NULL,
    fulladmin boolean DEFAULT false,
    notify_on_changes boolean DEFAULT false,
    password_reset_required boolean DEFAULT false,
    user_disabled boolean DEFAULT false,
    time_zone character varying DEFAULT 'Pacific Time (US & Canada)'::character varying,
    organization text,
    title text,
    phone text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    provider character varying,
    uid character varying,
    user_enabled boolean,
    organizations character varying
);


ALTER TABLE public.users OWNER TO admin;

--
-- TOC entry 177 (class 1259 OID 1314148)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO admin;

--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 177
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 2503 (class 2604 OID 1314379)
-- Name: action_items id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.action_items ALTER COLUMN id SET DEFAULT nextval('public.action_items_id_seq'::regclass);


--
-- TOC entry 2508 (class 2604 OID 1314501)
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- TOC entry 2507 (class 2604 OID 1314489)
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- TOC entry 2520 (class 2604 OID 1314779)
-- Name: archives id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.archives ALTER COLUMN id SET DEFAULT nextval('public.archives_id_seq'::regclass);


--
-- TOC entry 2513 (class 2604 OID 1314615)
-- Name: change_sessions id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.change_sessions ALTER COLUMN id SET DEFAULT nextval('public.change_sessions_id_seq'::regclass);


--
-- TOC entry 2502 (class 2604 OID 1314356)
-- Name: checklist_items id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.checklist_items ALTER COLUMN id SET DEFAULT nextval('public.checklist_items_id_seq'::regclass);


--
-- TOC entry 2525 (class 2604 OID 1314875)
-- Name: code_checkmark_hits id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_checkmark_hits ALTER COLUMN id SET DEFAULT nextval('public.code_checkmark_hits_id_seq'::regclass);


--
-- TOC entry 2524 (class 2604 OID 1314856)
-- Name: code_checkmarks id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_checkmarks ALTER COLUMN id SET DEFAULT nextval('public.code_checkmarks_id_seq'::regclass);


--
-- TOC entry 2526 (class 2604 OID 1314893)
-- Name: code_conditional_blocks id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_conditional_blocks ALTER COLUMN id SET DEFAULT nextval('public.code_conditional_blocks_id_seq'::regclass);


--
-- TOC entry 2523 (class 2604 OID 1314843)
-- Name: constants id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.constants ALTER COLUMN id SET DEFAULT nextval('public.constants_id_seq'::regclass);


--
-- TOC entry 2512 (class 2604 OID 1314601)
-- Name: data_changes id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.data_changes ALTER COLUMN id SET DEFAULT nextval('public.data_changes_id_seq'::regclass);


--
-- TOC entry 2509 (class 2604 OID 1314514)
-- Name: document_attachments id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_attachments ALTER COLUMN id SET DEFAULT nextval('public.document_attachments_id_seq'::regclass);


--
-- TOC entry 2501 (class 2604 OID 1314327)
-- Name: document_comments id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_comments ALTER COLUMN id SET DEFAULT nextval('public.document_comments_id_seq'::regclass);


--
-- TOC entry 2528 (class 2604 OID 1314969)
-- Name: document_types id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_types ALTER COLUMN id SET DEFAULT nextval('public.document_types_id_seq'::regclass);


--
-- TOC entry 2498 (class 2604 OID 1314270)
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- TOC entry 2515 (class 2604 OID 1314660)
-- Name: github_accesses id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.github_accesses ALTER COLUMN id SET DEFAULT nextval('public.github_accesses_id_seq'::regclass);


--
-- TOC entry 2521 (class 2604 OID 1314807)
-- Name: gitlab_accesses id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.gitlab_accesses ALTER COLUMN id SET DEFAULT nextval('public.gitlab_accesses_id_seq'::regclass);


--
-- TOC entry 2494 (class 2604 OID 1314215)
-- Name: high_level_requirements id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.high_level_requirements ALTER COLUMN id SET DEFAULT nextval('public.high_level_requirements_id_seq'::regclass);


--
-- TOC entry 2488 (class 2604 OID 1314193)
-- Name: items id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- TOC entry 2529 (class 2604 OID 1314987)
-- Name: licensees id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.licensees ALTER COLUMN id SET DEFAULT nextval('public.licensees_id_seq'::regclass);


--
-- TOC entry 2500 (class 2604 OID 1314302)
-- Name: low_level_requirements id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.low_level_requirements ALTER COLUMN id SET DEFAULT nextval('public.low_level_requirements_id_seq'::regclass);


--
-- TOC entry 2530 (class 2604 OID 1315029)
-- Name: model_files id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_files ALTER COLUMN id SET DEFAULT nextval('public.model_files_id_seq'::regclass);


--
-- TOC entry 2511 (class 2604 OID 1314572)
-- Name: problem_report_attachments id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_attachments ALTER COLUMN id SET DEFAULT nextval('public.problem_report_attachments_id_seq'::regclass);


--
-- TOC entry 2505 (class 2604 OID 1314431)
-- Name: problem_report_histories id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_histories ALTER COLUMN id SET DEFAULT nextval('public.problem_report_histories_id_seq'::regclass);


--
-- TOC entry 2504 (class 2604 OID 1314408)
-- Name: problem_reports id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_reports ALTER COLUMN id SET DEFAULT nextval('public.problem_reports_id_seq'::regclass);


--
-- TOC entry 2519 (class 2604 OID 1314728)
-- Name: project_accesses id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.project_accesses ALTER COLUMN id SET DEFAULT nextval('public.project_accesses_id_seq'::regclass);


--
-- TOC entry 2475 (class 2604 OID 1314140)
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- TOC entry 2510 (class 2604 OID 1314543)
-- Name: review_attachments id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.review_attachments ALTER COLUMN id SET DEFAULT nextval('public.review_attachments_id_seq'::regclass);


--
-- TOC entry 2495 (class 2604 OID 1314245)
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- TOC entry 2514 (class 2604 OID 1314630)
-- Name: source_codes id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.source_codes ALTER COLUMN id SET DEFAULT nextval('public.source_codes_id_seq'::regclass);


--
-- TOC entry 2487 (class 2604 OID 1314174)
-- Name: system_requirements id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_requirements ALTER COLUMN id SET DEFAULT nextval('public.system_requirements_id_seq'::regclass);


--
-- TOC entry 2518 (class 2604 OID 1314706)
-- Name: template_checklist_items id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_checklist_items ALTER COLUMN id SET DEFAULT nextval('public.template_checklist_items_id_seq'::regclass);


--
-- TOC entry 2517 (class 2604 OID 1314689)
-- Name: template_checklists id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_checklists ALTER COLUMN id SET DEFAULT nextval('public.template_checklists_id_seq'::regclass);


--
-- TOC entry 2522 (class 2604 OID 1314826)
-- Name: template_documents id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_documents ALTER COLUMN id SET DEFAULT nextval('public.template_documents_id_seq'::regclass);


--
-- TOC entry 2516 (class 2604 OID 1314678)
-- Name: templates id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.templates ALTER COLUMN id SET DEFAULT nextval('public.templates_id_seq'::regclass);


--
-- TOC entry 2506 (class 2604 OID 1314459)
-- Name: test_cases id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_cases ALTER COLUMN id SET DEFAULT nextval('public.test_cases_id_seq'::regclass);


--
-- TOC entry 2527 (class 2604 OID 1314911)
-- Name: test_procedures id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_procedures ALTER COLUMN id SET DEFAULT nextval('public.test_procedures_id_seq'::regclass);


--
-- TOC entry 2478 (class 2604 OID 1314153)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 2973 (class 0 OID 1314376)
-- Dependencies: 197
-- Data for Name: action_items; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2985 (class 0 OID 1314498)
-- Dependencies: 209
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2983 (class 0 OID 1314486)
-- Dependencies: 207
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2950 (class 0 OID 1314127)
-- Dependencies: 174
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.ar_internal_metadata VALUES ('environment', 'development', '2020-07-22 19:58:58.41608', '2020-07-22 19:58:58.41608');


--
-- TOC entry 3012 (class 0 OID 1314776)
-- Dependencies: 236
-- Data for Name: archives; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2996 (class 0 OID 1314612)
-- Dependencies: 220
-- Data for Name: change_sessions; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2971 (class 0 OID 1314353)
-- Dependencies: 195
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3022 (class 0 OID 1314872)
-- Dependencies: 246
-- Data for Name: code_checkmark_hits; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3020 (class 0 OID 1314853)
-- Dependencies: 244
-- Data for Name: code_checkmarks; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3024 (class 0 OID 1314890)
-- Dependencies: 248
-- Data for Name: code_conditional_blocks; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3018 (class 0 OID 1314840)
-- Dependencies: 242
-- Data for Name: constants; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2993 (class 0 OID 1314598)
-- Dependencies: 217
-- Data for Name: data_changes; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2987 (class 0 OID 1314511)
-- Dependencies: 211
-- Data for Name: document_attachments; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2969 (class 0 OID 1314324)
-- Dependencies: 193
-- Data for Name: document_comments; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3032 (class 0 OID 1314966)
-- Dependencies: 256
-- Data for Name: document_types; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2965 (class 0 OID 1314267)
-- Dependencies: 189
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3001 (class 0 OID 1314657)
-- Dependencies: 225
-- Data for Name: github_accesses; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3014 (class 0 OID 1314804)
-- Dependencies: 238
-- Data for Name: gitlab_accesses; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2960 (class 0 OID 1314212)
-- Dependencies: 184
-- Data for Name: high_level_requirements; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3033 (class 0 OID 1314977)
-- Dependencies: 257
-- Data for Name: hlr_hlrs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2978 (class 0 OID 1314449)
-- Dependencies: 202
-- Data for Name: hlr_llrs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3039 (class 0 OID 1315060)
-- Dependencies: 263
-- Data for Name: hlr_mfs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3008 (class 0 OID 1314718)
-- Dependencies: 232
-- Data for Name: hlr_scs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2981 (class 0 OID 1314479)
-- Dependencies: 205
-- Data for Name: hlr_tcs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3027 (class 0 OID 1314938)
-- Dependencies: 251
-- Data for Name: hlr_tps; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2958 (class 0 OID 1314190)
-- Dependencies: 182
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3035 (class 0 OID 1314984)
-- Dependencies: 259
-- Data for Name: licensees; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3040 (class 0 OID 1315065)
-- Dependencies: 264
-- Data for Name: llr_mfs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2999 (class 0 OID 1314650)
-- Dependencies: 223
-- Data for Name: llr_scs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3029 (class 0 OID 1314953)
-- Dependencies: 253
-- Data for Name: llr_tcs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3028 (class 0 OID 1314943)
-- Dependencies: 252
-- Data for Name: llr_tps; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2967 (class 0 OID 1314299)
-- Dependencies: 191
-- Data for Name: low_level_requirements; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3037 (class 0 OID 1315026)
-- Dependencies: 261
-- Data for Name: model_files; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2991 (class 0 OID 1314569)
-- Dependencies: 215
-- Data for Name: problem_report_attachments; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2977 (class 0 OID 1314428)
-- Dependencies: 201
-- Data for Name: problem_report_histories; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2975 (class 0 OID 1314405)
-- Dependencies: 199
-- Data for Name: problem_reports; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3010 (class 0 OID 1314725)
-- Dependencies: 234
-- Data for Name: project_accesses; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2952 (class 0 OID 1314137)
-- Dependencies: 176
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2989 (class 0 OID 1314540)
-- Dependencies: 213
-- Data for Name: review_attachments; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2963 (class 0 OID 1314242)
-- Dependencies: 187
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2949 (class 0 OID 1314119)
-- Dependencies: 173
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.schema_migrations VALUES ('20171204014458');
INSERT INTO public.schema_migrations VALUES ('20171220232336');
INSERT INTO public.schema_migrations VALUES ('20180102215052');
INSERT INTO public.schema_migrations VALUES ('20180118222946');
INSERT INTO public.schema_migrations VALUES ('20180130013408');
INSERT INTO public.schema_migrations VALUES ('20180221222956');
INSERT INTO public.schema_migrations VALUES ('20180314000000');
INSERT INTO public.schema_migrations VALUES ('20180314010938');
INSERT INTO public.schema_migrations VALUES ('20180324160917');
INSERT INTO public.schema_migrations VALUES ('20180324161321');
INSERT INTO public.schema_migrations VALUES ('20180324192922');
INSERT INTO public.schema_migrations VALUES ('20180324194003');
INSERT INTO public.schema_migrations VALUES ('20180324194420');
INSERT INTO public.schema_migrations VALUES ('20180324194536');
INSERT INTO public.schema_migrations VALUES ('20180425232555');
INSERT INTO public.schema_migrations VALUES ('20180429134952');
INSERT INTO public.schema_migrations VALUES ('20180429142641');
INSERT INTO public.schema_migrations VALUES ('20180623145132');
INSERT INTO public.schema_migrations VALUES ('20180715133136');
INSERT INTO public.schema_migrations VALUES ('20180724210516');
INSERT INTO public.schema_migrations VALUES ('20180724210625');
INSERT INTO public.schema_migrations VALUES ('20180922170351');
INSERT INTO public.schema_migrations VALUES ('20190610194953');
INSERT INTO public.schema_migrations VALUES ('20190620224911');
INSERT INTO public.schema_migrations VALUES ('20190621144932');
INSERT INTO public.schema_migrations VALUES ('20190701210357');
INSERT INTO public.schema_migrations VALUES ('20190708184653');
INSERT INTO public.schema_migrations VALUES ('20190814142900');
INSERT INTO public.schema_migrations VALUES ('20190821154420');
INSERT INTO public.schema_migrations VALUES ('20190821175610');
INSERT INTO public.schema_migrations VALUES ('20190821232555');
INSERT INTO public.schema_migrations VALUES ('20190821235556');
INSERT INTO public.schema_migrations VALUES ('20190827161305');
INSERT INTO public.schema_migrations VALUES ('20190827221533');
INSERT INTO public.schema_migrations VALUES ('20190905191900');
INSERT INTO public.schema_migrations VALUES ('20190905192900');
INSERT INTO public.schema_migrations VALUES ('20190905192922');
INSERT INTO public.schema_migrations VALUES ('20190920161305');
INSERT INTO public.schema_migrations VALUES ('20191001232555');
INSERT INTO public.schema_migrations VALUES ('20191002211928');
INSERT INTO public.schema_migrations VALUES ('20191014211928');
INSERT INTO public.schema_migrations VALUES ('20191016161732');
INSERT INTO public.schema_migrations VALUES ('20191017231732');
INSERT INTO public.schema_migrations VALUES ('20191022211928');
INSERT INTO public.schema_migrations VALUES ('20191030221533');
INSERT INTO public.schema_migrations VALUES ('20191101192900');
INSERT INTO public.schema_migrations VALUES ('20191106192900');
INSERT INTO public.schema_migrations VALUES ('20191112192900');
INSERT INTO public.schema_migrations VALUES ('20191113161305');
INSERT INTO public.schema_migrations VALUES ('20191113220005');
INSERT INTO public.schema_migrations VALUES ('20191114161305');
INSERT INTO public.schema_migrations VALUES ('20191120214005');
INSERT INTO public.schema_migrations VALUES ('20191127000405');
INSERT INTO public.schema_migrations VALUES ('20191127164705');
INSERT INTO public.schema_migrations VALUES ('20191203161005');
INSERT INTO public.schema_migrations VALUES ('20191204002105');
INSERT INTO public.schema_migrations VALUES ('20191205230000');
INSERT INTO public.schema_migrations VALUES ('20191206211000');
INSERT INTO public.schema_migrations VALUES ('20191212170500');
INSERT INTO public.schema_migrations VALUES ('20191212172500');
INSERT INTO public.schema_migrations VALUES ('20191212205000');
INSERT INTO public.schema_migrations VALUES ('20191216162500');
INSERT INTO public.schema_migrations VALUES ('20191220232055');
INSERT INTO public.schema_migrations VALUES ('20191220232451');
INSERT INTO public.schema_migrations VALUES ('20200108232055');
INSERT INTO public.schema_migrations VALUES ('20200109161555');
INSERT INTO public.schema_migrations VALUES ('20200110132925');
INSERT INTO public.schema_migrations VALUES ('20200114161849');
INSERT INTO public.schema_migrations VALUES ('20200121235403');
INSERT INTO public.schema_migrations VALUES ('20200123175023');
INSERT INTO public.schema_migrations VALUES ('20200221181407');
INSERT INTO public.schema_migrations VALUES ('20200231181407');
INSERT INTO public.schema_migrations VALUES ('20200316191905');
INSERT INTO public.schema_migrations VALUES ('20200318112605');
INSERT INTO public.schema_migrations VALUES ('20200319151300');
INSERT INTO public.schema_migrations VALUES ('20200319152700');
INSERT INTO public.schema_migrations VALUES ('20200319153100');
INSERT INTO public.schema_migrations VALUES ('20200319153500');
INSERT INTO public.schema_migrations VALUES ('20200319200000');
INSERT INTO public.schema_migrations VALUES ('20200320182000');
INSERT INTO public.schema_migrations VALUES ('20200324172137');
INSERT INTO public.schema_migrations VALUES ('20200414203827');
INSERT INTO public.schema_migrations VALUES ('20200417223051');
INSERT INTO public.schema_migrations VALUES ('20200420160906');
INSERT INTO public.schema_migrations VALUES ('20200421194103');
INSERT INTO public.schema_migrations VALUES ('20200423154010');
INSERT INTO public.schema_migrations VALUES ('20200424184113');
INSERT INTO public.schema_migrations VALUES ('20200428184011');
INSERT INTO public.schema_migrations VALUES ('20200428184104');
INSERT INTO public.schema_migrations VALUES ('20200428205901');
INSERT INTO public.schema_migrations VALUES ('20200429144740');
INSERT INTO public.schema_migrations VALUES ('20200501210627');
INSERT INTO public.schema_migrations VALUES ('20200504213338');
INSERT INTO public.schema_migrations VALUES ('20200506165828');
INSERT INTO public.schema_migrations VALUES ('20200511210710');
INSERT INTO public.schema_migrations VALUES ('20200518141925');
INSERT INTO public.schema_migrations VALUES ('20200603153451');
INSERT INTO public.schema_migrations VALUES ('20200605170810');
INSERT INTO public.schema_migrations VALUES ('20200611155053');
INSERT INTO public.schema_migrations VALUES ('20200623171001');
INSERT INTO public.schema_migrations VALUES ('20200630154758');
INSERT INTO public.schema_migrations VALUES ('20200703153612');
INSERT INTO public.schema_migrations VALUES ('20200714174819');


--
-- TOC entry 2998 (class 0 OID 1314627)
-- Dependencies: 222
-- Data for Name: source_codes; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2961 (class 0 OID 1314235)
-- Dependencies: 185
-- Data for Name: sysreq_hlrs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3038 (class 0 OID 1315055)
-- Dependencies: 262
-- Data for Name: sysreq_mfs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2956 (class 0 OID 1314171)
-- Dependencies: 180
-- Data for Name: system_requirements; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3041 (class 0 OID 1315070)
-- Dependencies: 265
-- Data for Name: tc_mfs; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3030 (class 0 OID 1314956)
-- Dependencies: 254
-- Data for Name: tcs_tps; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3007 (class 0 OID 1314703)
-- Dependencies: 231
-- Data for Name: template_checklist_items; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3005 (class 0 OID 1314686)
-- Dependencies: 229
-- Data for Name: template_checklists; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3016 (class 0 OID 1314823)
-- Dependencies: 240
-- Data for Name: template_documents; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3003 (class 0 OID 1314675)
-- Dependencies: 227
-- Data for Name: templates; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2980 (class 0 OID 1314456)
-- Dependencies: 204
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3026 (class 0 OID 1314908)
-- Dependencies: 250
-- Data for Name: test_procedures; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 2954 (class 0 OID 1314150)
-- Dependencies: 178
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.users VALUES (135138680, 'admin@faaconsultants.com', '$2a$11$hUPhLZMv9RO9j6eMXmJLi.x3jqYOXTl/YpkfyXH1QD2kGkYxbgc86', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Admin', 'User', '---
- AirWorthinessCert Member
', true, false, false, false, 'Pacific Time (US & Canada)', 'global', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (193540442, 'info@airworthinesscert.com', '$2a$11$.JBnA.V2M5sI5LEnAGmzweoZ77/NCPR1OAFi2ZCxzhr8m02o79kcC', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Michelle', 'Lange', '---
- AirWorthinessCert Member
', true, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (589712652, 'paul@patmos-eng.com', '$2a$11$8SI10BxBfEUxurOSCRyqlOYQg/cxGnOgYZ680OEWZ7JBKcESjIVcm', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Paul', 'Carrick', '---
- AirWorthinessCert Member
- Project Manager
- Configuration Management
- Quality Assurance
- Team Member
', true, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (220229288, 'paul@airworthinesscert.com', '$2a$11$VpWUD6yjQbo8XKi5QDcUYuhi24DuJh8FzDsizqM/Pwo.tG9fHY/qq', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Paul', 'Carrick*', '---
- Project Manager
- Configuration Management
- Quality Assurance
- Team Member
', false, false, false, false, 'Pacific Time (US & Canada)', 'airworthiness_certification_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (732311030, 'paul.j.carrick@gmail.com', '$2a$11$K15S.X5wygSBwoeJ8U.TL.q125rr/LH6LysA1gB2lVQKszvMfSqhC', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Paul', 'Carrick**', '---
- Configuration Management
- Quality Assurance
- Team Member
', false, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (230535003, 'pauljcarrick@gmail.com', '$2a$11$nnoVlicmy4TTGxwxpYetm.mRureGNyaTogJFn8KeRUVbOjjed4/Kq', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Paul', 'Carrick***', '---
- Team Member
', false, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (170570858, 'paul.and.virginia.carrick@gmail.com', '$2a$11$wOOhBhibZA5jHkCh7sXAteww2VzOmZRV5RqVy3b5W9kJtDb0Md8nG', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Paul', 'Carrick****', '---
- Restricted View
', false, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (667199673, 'paulandvirginia.carrick@gmail.com', '$2a$11$aWdiTtbX1cMqP/V.ZRcy2eU.vk/jSL/zdsSZwCorKkmwjoBuZLkga', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Paul', 'Carrick*****', '---
- Demo User
', false, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (1062247836, 'steve@patmos-eng.com', '$2a$11$5PlTb7xFx4KS1/vvNiTMUusac6Y7l6p3C3kGm9jpaskpRlZ2nK7JC', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Steve', 'Gregor', '---
- AirWorthinessCert Member
- Team Member
', true, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (778413638, 'michelle@altech-marketing.com', '$2a$11$wjzSYlX8KDPOTPnqxgIfIOMd5X8okOa6SblXDFnHajpD526Zdmnye', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Michelle', 'Lange', '---
- AirWorthinessCert Member
- Project Manager
- Configuration Management
- Quality Assurance
- Team Member
', true, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (856226576, 'gm_consulting@comcast.net', '$2a$11$q01brA/wbwaKuOU2MacVS.DyR9HembWzw.DNiMbryUGYErJ5IqnIG', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Michelle', 'Lange*', '---
- AirWorthinessCert Member
- Project Manager
- Configuration Management
- Quality Assurance
- Team Member
', false, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (37725344, 'tammy@patmos-eng.com', '$2a$11$OFeEDDVW940vcTo8mCNiT.ERUSeV05OjY7qHFcUg4I.z10IO58OJi', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Tammy', 'Reeve', '---
- AirWorthinessCert Member
- Project Manager
- Configuration Management
- Quality Assurance
- Team Member
', true, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES (466345389, 'dave@patmos-eng.com', '$2a$11$n3dQeoo2Omy..yJtMisQNO0m8enKV1KYSh08uiAceqPK41cCIqV5C', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'Dave', 'Newton', '---
- AirWorthinessCert Member
- Project Manager
- Configuration Management
- Quality Assurance
- Team Member
', false, false, false, false, 'Pacific Time (US & Canada)', 'patmos_engineering_services', NULL, NULL, '2020-07-22 20:04:33.822557', '2020-07-22 20:04:33.822557', NULL, NULL, NULL, NULL);


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 196
-- Name: action_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.action_items_id_seq', 1, false);


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 208
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.active_storage_attachments_id_seq', 1, false);


--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 206
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.active_storage_blobs_id_seq', 1, false);


--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 235
-- Name: archives_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.archives_id_seq', 1, false);


--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 219
-- Name: change_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.change_sessions_id_seq', 1, false);


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 194
-- Name: checklist_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.checklist_items_id_seq', 1, false);


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 245
-- Name: code_checkmark_hits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.code_checkmark_hits_id_seq', 1, false);


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 243
-- Name: code_checkmarks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.code_checkmarks_id_seq', 1, false);


--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 247
-- Name: code_conditional_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.code_conditional_blocks_id_seq', 1, false);


--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 241
-- Name: constants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.constants_id_seq', 1, false);


--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 216
-- Name: data_changes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.data_changes_id_seq', 1, false);


--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 210
-- Name: document_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.document_attachments_id_seq', 1, false);


--
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 192
-- Name: document_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.document_comments_id_seq', 1, false);


--
-- TOC entry 3099 (class 0 OID 0)
-- Dependencies: 255
-- Name: document_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.document_types_id_seq', 1, false);


--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 188
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.documents_id_seq', 1, false);


--
-- TOC entry 3101 (class 0 OID 0)
-- Dependencies: 224
-- Name: github_accesses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.github_accesses_id_seq', 1, false);


--
-- TOC entry 3102 (class 0 OID 0)
-- Dependencies: 237
-- Name: gitlab_accesses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.gitlab_accesses_id_seq', 1, false);


--
-- TOC entry 3103 (class 0 OID 0)
-- Dependencies: 183
-- Name: high_level_requirements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.high_level_requirements_id_seq', 1, false);


--
-- TOC entry 3104 (class 0 OID 0)
-- Dependencies: 181
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.items_id_seq', 1, false);


--
-- TOC entry 3105 (class 0 OID 0)
-- Dependencies: 258
-- Name: licensees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.licensees_id_seq', 1, false);


--
-- TOC entry 3106 (class 0 OID 0)
-- Dependencies: 190
-- Name: low_level_requirements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.low_level_requirements_id_seq', 1, false);


--
-- TOC entry 3107 (class 0 OID 0)
-- Dependencies: 260
-- Name: model_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.model_files_id_seq', 1, false);


--
-- TOC entry 3108 (class 0 OID 0)
-- Dependencies: 214
-- Name: problem_report_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.problem_report_attachments_id_seq', 1, false);


--
-- TOC entry 3109 (class 0 OID 0)
-- Dependencies: 200
-- Name: problem_report_histories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.problem_report_histories_id_seq', 1, false);


--
-- TOC entry 3110 (class 0 OID 0)
-- Dependencies: 198
-- Name: problem_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.problem_reports_id_seq', 1, false);


--
-- TOC entry 3111 (class 0 OID 0)
-- Dependencies: 233
-- Name: project_accesses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.project_accesses_id_seq', 1, false);


--
-- TOC entry 3112 (class 0 OID 0)
-- Dependencies: 175
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.projects_id_seq', 1, false);


--
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 212
-- Name: review_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.review_attachments_id_seq', 1, false);


--
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 186
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.reviews_id_seq', 1, false);


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 218
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.session_id_seq', 1, false);


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 221
-- Name: source_codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.source_codes_id_seq', 1, false);


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 179
-- Name: system_requirements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.system_requirements_id_seq', 1, false);


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 230
-- Name: template_checklist_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.template_checklist_items_id_seq', 1, false);


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 228
-- Name: template_checklists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.template_checklists_id_seq', 1, false);


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 239
-- Name: template_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.template_documents_id_seq', 1, false);


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 226
-- Name: templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.templates_id_seq', 1, false);


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 203
-- Name: test_cases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.test_cases_id_seq', 1, false);


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 249
-- Name: test_procedures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.test_procedures_id_seq', 1, false);


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 177
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.users_id_seq', 1062247836, true);


--
-- TOC entry 2609 (class 2606 OID 1314384)
-- Name: action_items action_items_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.action_items
    ADD CONSTRAINT action_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2645 (class 2606 OID 1314506)
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 2642 (class 2606 OID 1314494)
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- TOC entry 2534 (class 2606 OID 1314134)
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- TOC entry 2713 (class 2606 OID 1314784)
-- Name: archives archives_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.archives
    ADD CONSTRAINT archives_pkey PRIMARY KEY (id);


--
-- TOC entry 2674 (class 2606 OID 1314617)
-- Name: change_sessions change_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.change_sessions
    ADD CONSTRAINT change_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 2602 (class 2606 OID 1314361)
-- Name: checklist_items checklist_items_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT checklist_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2732 (class 2606 OID 1314880)
-- Name: code_checkmark_hits code_checkmark_hits_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_checkmark_hits
    ADD CONSTRAINT code_checkmark_hits_pkey PRIMARY KEY (id);


--
-- TOC entry 2728 (class 2606 OID 1314861)
-- Name: code_checkmarks code_checkmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_checkmarks
    ADD CONSTRAINT code_checkmarks_pkey PRIMARY KEY (id);


--
-- TOC entry 2735 (class 2606 OID 1314898)
-- Name: code_conditional_blocks code_conditional_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_conditional_blocks
    ADD CONSTRAINT code_conditional_blocks_pkey PRIMARY KEY (id);


--
-- TOC entry 2725 (class 2606 OID 1314848)
-- Name: constants constants_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.constants
    ADD CONSTRAINT constants_pkey PRIMARY KEY (id);


--
-- TOC entry 2670 (class 2606 OID 1314606)
-- Name: data_changes data_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.data_changes
    ADD CONSTRAINT data_changes_pkey PRIMARY KEY (id);


--
-- TOC entry 2649 (class 2606 OID 1314519)
-- Name: document_attachments document_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_attachments
    ADD CONSTRAINT document_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 2595 (class 2606 OID 1314332)
-- Name: document_comments document_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_comments
    ADD CONSTRAINT document_comments_pkey PRIMARY KEY (id);


--
-- TOC entry 2756 (class 2606 OID 1314974)
-- Name: document_types document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


--
-- TOC entry 2576 (class 2606 OID 1314276)
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- TOC entry 2689 (class 2606 OID 1314665)
-- Name: github_accesses github_accesses_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.github_accesses
    ADD CONSTRAINT github_accesses_pkey PRIMARY KEY (id);


--
-- TOC entry 2717 (class 2606 OID 1314812)
-- Name: gitlab_accesses gitlab_accesses_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.gitlab_accesses
    ADD CONSTRAINT gitlab_accesses_pkey PRIMARY KEY (id);


--
-- TOC entry 2558 (class 2606 OID 1314220)
-- Name: high_level_requirements high_level_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.high_level_requirements
    ADD CONSTRAINT high_level_requirements_pkey PRIMARY KEY (id);


--
-- TOC entry 2556 (class 2606 OID 1314203)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 2762 (class 2606 OID 1314992)
-- Name: licensees licensees_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.licensees
    ADD CONSTRAINT licensees_pkey PRIMARY KEY (id);


--
-- TOC entry 2593 (class 2606 OID 1314307)
-- Name: low_level_requirements low_level_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.low_level_requirements
    ADD CONSTRAINT low_level_requirements_pkey PRIMARY KEY (id);


--
-- TOC entry 2769 (class 2606 OID 1315034)
-- Name: model_files model_files_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_files
    ADD CONSTRAINT model_files_pkey PRIMARY KEY (id);


--
-- TOC entry 2668 (class 2606 OID 1314577)
-- Name: problem_report_attachments problem_report_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_attachments
    ADD CONSTRAINT problem_report_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 2626 (class 2606 OID 1314436)
-- Name: problem_report_histories problem_report_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_histories
    ADD CONSTRAINT problem_report_histories_pkey PRIMARY KEY (id);


--
-- TOC entry 2620 (class 2606 OID 1314413)
-- Name: problem_reports problem_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_reports
    ADD CONSTRAINT problem_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 2711 (class 2606 OID 1314733)
-- Name: project_accesses project_accesses_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.project_accesses
    ADD CONSTRAINT project_accesses_pkey PRIMARY KEY (id);


--
-- TOC entry 2538 (class 2606 OID 1314147)
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- TOC entry 2661 (class 2606 OID 1314548)
-- Name: review_attachments review_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.review_attachments
    ADD CONSTRAINT review_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 2574 (class 2606 OID 1314252)
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- TOC entry 2532 (class 2606 OID 1314126)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 2685 (class 2606 OID 1314635)
-- Name: source_codes source_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.source_codes
    ADD CONSTRAINT source_codes_pkey PRIMARY KEY (id);


--
-- TOC entry 2551 (class 2606 OID 1314179)
-- Name: system_requirements system_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_requirements
    ADD CONSTRAINT system_requirements_pkey PRIMARY KEY (id);


--
-- TOC entry 2703 (class 2606 OID 1314711)
-- Name: template_checklist_items template_checklist_items_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_checklist_items
    ADD CONSTRAINT template_checklist_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2699 (class 2606 OID 1314694)
-- Name: template_checklists template_checklists_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_checklists
    ADD CONSTRAINT template_checklists_pkey PRIMARY KEY (id);


--
-- TOC entry 2723 (class 2606 OID 1314831)
-- Name: template_documents template_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_documents
    ADD CONSTRAINT template_documents_pkey PRIMARY KEY (id);


--
-- TOC entry 2695 (class 2606 OID 1314683)
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- TOC entry 2638 (class 2606 OID 1314464)
-- Name: test_cases test_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_cases
    ADD CONSTRAINT test_cases_pkey PRIMARY KEY (id);


--
-- TOC entry 2746 (class 2606 OID 1314916)
-- Name: test_procedures test_procedures_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_procedures
    ADD CONSTRAINT test_procedures_pkey PRIMARY KEY (id);


--
-- TOC entry 2542 (class 2606 OID 1314166)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2671 (class 1259 OID 1314993)
-- Name: data_changes_primary_index; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX data_changes_primary_index ON public.data_changes USING btree (changed_by, table_name, table_id, action, performed_at, change_type);


--
-- TOC entry 2610 (class 1259 OID 1314794)
-- Name: index_action_items_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_action_items_on_archive_id ON public.action_items USING btree (archive_id);


--
-- TOC entry 2611 (class 1259 OID 1314400)
-- Name: index_action_items_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_action_items_on_item_id ON public.action_items USING btree (item_id);


--
-- TOC entry 2612 (class 1259 OID 1314756)
-- Name: index_action_items_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_action_items_on_organization ON public.action_items USING btree (organization);


--
-- TOC entry 2613 (class 1259 OID 1314401)
-- Name: index_action_items_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_action_items_on_project_id ON public.action_items USING btree (project_id);


--
-- TOC entry 2614 (class 1259 OID 1314402)
-- Name: index_action_items_on_review_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_action_items_on_review_id ON public.action_items USING btree (review_id);


--
-- TOC entry 2646 (class 1259 OID 1314507)
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- TOC entry 2647 (class 1259 OID 1314508)
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- TOC entry 2643 (class 1259 OID 1314495)
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- TOC entry 2714 (class 1259 OID 1315099)
-- Name: index_archives_on_archive_type; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_archives_on_archive_type ON public.archives USING btree (archive_type);


--
-- TOC entry 2715 (class 1259 OID 1314963)
-- Name: index_archives_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_archives_on_project_id ON public.archives USING btree (project_id);


--
-- TOC entry 2736 (class 1259 OID 1314905)
-- Name: index_blocks_on_source_code_filename_and_line_numbers; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_blocks_on_source_code_filename_and_line_numbers ON public.code_conditional_blocks USING btree (source_code_id, filename, start_line_number, end_line_number);


--
-- TOC entry 2675 (class 1259 OID 1314623)
-- Name: index_change_sessions_on_data_change_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_change_sessions_on_data_change_id ON public.change_sessions USING btree (data_change_id);


--
-- TOC entry 2676 (class 1259 OID 1314767)
-- Name: index_change_sessions_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_change_sessions_on_organization ON public.change_sessions USING btree (organization);


--
-- TOC entry 2677 (class 1259 OID 1314624)
-- Name: index_change_sessions_on_session_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_change_sessions_on_session_id ON public.change_sessions USING btree (session_id);


--
-- TOC entry 2603 (class 1259 OID 1314793)
-- Name: index_checklist_items_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_checklist_items_on_archive_id ON public.checklist_items USING btree (archive_id);


--
-- TOC entry 2604 (class 1259 OID 1314373)
-- Name: index_checklist_items_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_checklist_items_on_document_id ON public.checklist_items USING btree (document_id);


--
-- TOC entry 2605 (class 1259 OID 1314755)
-- Name: index_checklist_items_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_checklist_items_on_organization ON public.checklist_items USING btree (organization);


--
-- TOC entry 2606 (class 1259 OID 1314372)
-- Name: index_checklist_items_on_review_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_checklist_items_on_review_id ON public.checklist_items USING btree (review_id);


--
-- TOC entry 2607 (class 1259 OID 1314850)
-- Name: index_checklist_items_on_user_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_checklist_items_on_user_id ON public.checklist_items USING btree (user_id);


--
-- TOC entry 2729 (class 1259 OID 1314887)
-- Name: index_checkmarks_on_id_filename_and_line_number; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_checkmarks_on_id_filename_and_line_number ON public.code_checkmarks USING btree (checkmark_id, filename, line_number);


--
-- TOC entry 2733 (class 1259 OID 1314886)
-- Name: index_code_checkmark_hits_on_code_checkmark_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_code_checkmark_hits_on_code_checkmark_id ON public.code_checkmark_hits USING btree (code_checkmark_id);


--
-- TOC entry 2730 (class 1259 OID 1314867)
-- Name: index_code_checkmarks_on_source_code_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_code_checkmarks_on_source_code_id ON public.code_checkmarks USING btree (source_code_id);


--
-- TOC entry 2737 (class 1259 OID 1314904)
-- Name: index_code_conditional_blocks_on_source_code_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_code_conditional_blocks_on_source_code_id ON public.code_conditional_blocks USING btree (source_code_id);


--
-- TOC entry 2726 (class 1259 OID 1314849)
-- Name: index_constants_on_name_and_label_and_value; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_constants_on_name_and_label_and_value ON public.constants USING btree (name, label, value);


--
-- TOC entry 2672 (class 1259 OID 1314763)
-- Name: index_data_changes_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_data_changes_on_organization ON public.data_changes USING btree (organization);


--
-- TOC entry 2650 (class 1259 OID 1314798)
-- Name: index_document_attachments_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_attachments_on_archive_id ON public.document_attachments USING btree (archive_id);


--
-- TOC entry 2651 (class 1259 OID 1314535)
-- Name: index_document_attachments_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_attachments_on_document_id ON public.document_attachments USING btree (document_id);


--
-- TOC entry 2652 (class 1259 OID 1314536)
-- Name: index_document_attachments_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_attachments_on_item_id ON public.document_attachments USING btree (item_id);


--
-- TOC entry 2653 (class 1259 OID 1314760)
-- Name: index_document_attachments_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_attachments_on_organization ON public.document_attachments USING btree (organization);


--
-- TOC entry 2654 (class 1259 OID 1314537)
-- Name: index_document_attachments_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_attachments_on_project_id ON public.document_attachments USING btree (project_id);


--
-- TOC entry 2596 (class 1259 OID 1314791)
-- Name: index_document_comments_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_comments_on_archive_id ON public.document_comments USING btree (archive_id);


--
-- TOC entry 2597 (class 1259 OID 1314350)
-- Name: index_document_comments_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_comments_on_document_id ON public.document_comments USING btree (document_id);


--
-- TOC entry 2598 (class 1259 OID 1314348)
-- Name: index_document_comments_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_comments_on_item_id ON public.document_comments USING btree (item_id);


--
-- TOC entry 2599 (class 1259 OID 1314753)
-- Name: index_document_comments_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_comments_on_organization ON public.document_comments USING btree (organization);


--
-- TOC entry 2600 (class 1259 OID 1314349)
-- Name: index_document_comments_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_comments_on_project_id ON public.document_comments USING btree (project_id);


--
-- TOC entry 2757 (class 1259 OID 1314976)
-- Name: index_document_types_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_document_types_on_organization ON public.document_types USING btree (organization);


--
-- TOC entry 2758 (class 1259 OID 1314975)
-- Name: index_document_types_on_type_item_types_dals_control_category; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_document_types_on_type_item_types_dals_control_category ON public.document_types USING btree (document_code, item_types, dal_levels, control_category);


--
-- TOC entry 2577 (class 1259 OID 1314789)
-- Name: index_documents_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_documents_on_archive_id ON public.documents USING btree (archive_id);


--
-- TOC entry 2578 (class 1259 OID 1314296)
-- Name: index_documents_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_documents_on_document_id ON public.documents USING btree (document_id);


--
-- TOC entry 2579 (class 1259 OID 1314292)
-- Name: index_documents_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_documents_on_item_id ON public.documents USING btree (item_id);


--
-- TOC entry 2580 (class 1259 OID 1314751)
-- Name: index_documents_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_documents_on_organization ON public.documents USING btree (organization);


--
-- TOC entry 2581 (class 1259 OID 1314295)
-- Name: index_documents_on_parent_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_documents_on_parent_id ON public.documents USING btree (parent_id);


--
-- TOC entry 2582 (class 1259 OID 1314293)
-- Name: index_documents_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_documents_on_project_id ON public.documents USING btree (project_id);


--
-- TOC entry 2583 (class 1259 OID 1314294)
-- Name: index_documents_on_review_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_documents_on_review_id ON public.documents USING btree (review_id);


--
-- TOC entry 2690 (class 1259 OID 1314672)
-- Name: index_github_accesses_on_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_github_accesses_on_id ON public.github_accesses USING btree (id);


--
-- TOC entry 2691 (class 1259 OID 1314769)
-- Name: index_github_accesses_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_github_accesses_on_organization ON public.github_accesses USING btree (organization);


--
-- TOC entry 2692 (class 1259 OID 1314671)
-- Name: index_github_accesses_on_user_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_github_accesses_on_user_id ON public.github_accesses USING btree (user_id);


--
-- TOC entry 2718 (class 1259 OID 1314819)
-- Name: index_gitlab_accesses_on_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_gitlab_accesses_on_id ON public.gitlab_accesses USING btree (id);


--
-- TOC entry 2719 (class 1259 OID 1314820)
-- Name: index_gitlab_accesses_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_gitlab_accesses_on_organization ON public.gitlab_accesses USING btree (organization);


--
-- TOC entry 2720 (class 1259 OID 1314818)
-- Name: index_gitlab_accesses_on_user_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_gitlab_accesses_on_user_id ON public.gitlab_accesses USING btree (user_id);


--
-- TOC entry 2559 (class 1259 OID 1314788)
-- Name: index_high_level_requirements_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_high_level_requirements_on_archive_id ON public.high_level_requirements USING btree (archive_id);


--
-- TOC entry 2560 (class 1259 OID 1315000)
-- Name: index_high_level_requirements_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_high_level_requirements_on_document_id ON public.high_level_requirements USING btree (document_id);


--
-- TOC entry 2561 (class 1259 OID 1314231)
-- Name: index_high_level_requirements_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_high_level_requirements_on_item_id ON public.high_level_requirements USING btree (item_id);


--
-- TOC entry 2562 (class 1259 OID 1315081)
-- Name: index_high_level_requirements_on_model_file_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_high_level_requirements_on_model_file_id ON public.high_level_requirements USING btree (model_file_id);


--
-- TOC entry 2563 (class 1259 OID 1314750)
-- Name: index_high_level_requirements_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_high_level_requirements_on_organization ON public.high_level_requirements USING btree (organization);


--
-- TOC entry 2564 (class 1259 OID 1314232)
-- Name: index_high_level_requirements_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_high_level_requirements_on_project_id ON public.high_level_requirements USING btree (project_id);


--
-- TOC entry 2759 (class 1259 OID 1314980)
-- Name: index_hlr_hlrs_on_high_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_hlrs_on_high_level_requirement_id ON public.hlr_hlrs USING btree (high_level_requirement_id);


--
-- TOC entry 2760 (class 1259 OID 1314981)
-- Name: index_hlr_hlrs_on_referenced_high_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_hlrs_on_referenced_high_level_requirement_id ON public.hlr_hlrs USING btree (referenced_high_level_requirement_id);


--
-- TOC entry 2627 (class 1259 OID 1314452)
-- Name: index_hlr_llrs_on_high_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_llrs_on_high_level_requirement_id ON public.hlr_llrs USING btree (high_level_requirement_id);


--
-- TOC entry 2628 (class 1259 OID 1314453)
-- Name: index_hlr_llrs_on_low_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_llrs_on_low_level_requirement_id ON public.hlr_llrs USING btree (low_level_requirement_id);


--
-- TOC entry 2772 (class 1259 OID 1315063)
-- Name: index_hlr_mfs_on_high_level_requirement_id_and_model_file_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_mfs_on_high_level_requirement_id_and_model_file_id ON public.hlr_mfs USING btree (high_level_requirement_id, model_file_id);


--
-- TOC entry 2773 (class 1259 OID 1315064)
-- Name: index_hlr_mfs_on_model_file_id_and_high_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_mfs_on_model_file_id_and_high_level_requirement_id ON public.hlr_mfs USING btree (model_file_id, high_level_requirement_id);


--
-- TOC entry 2704 (class 1259 OID 1314721)
-- Name: index_hlr_scs_on_high_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_scs_on_high_level_requirement_id ON public.hlr_scs USING btree (high_level_requirement_id);


--
-- TOC entry 2705 (class 1259 OID 1314722)
-- Name: index_hlr_scs_on_source_code_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_scs_on_source_code_id ON public.hlr_scs USING btree (source_code_id);


--
-- TOC entry 2639 (class 1259 OID 1314482)
-- Name: index_hlr_tcs_on_high_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_tcs_on_high_level_requirement_id ON public.hlr_tcs USING btree (high_level_requirement_id);


--
-- TOC entry 2640 (class 1259 OID 1314483)
-- Name: index_hlr_tcs_on_test_case_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_tcs_on_test_case_id ON public.hlr_tcs USING btree (test_case_id);


--
-- TOC entry 2747 (class 1259 OID 1314941)
-- Name: index_hlr_tps_on_high_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_tps_on_high_level_requirement_id ON public.hlr_tps USING btree (high_level_requirement_id);


--
-- TOC entry 2748 (class 1259 OID 1314942)
-- Name: index_hlr_tps_on_test_procedure_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_hlr_tps_on_test_procedure_id ON public.hlr_tps USING btree (test_procedure_id);


--
-- TOC entry 2565 (class 1259 OID 1315103)
-- Name: index_hlrs_on_full_id_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_hlrs_on_full_id_and_project_id_and_item_id ON public.high_level_requirements USING btree (full_id, project_id, item_id, archive_id);


--
-- TOC entry 2566 (class 1259 OID 1315102)
-- Name: index_hlrs_on_reqid_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_hlrs_on_reqid_and_project_id_and_item_id ON public.high_level_requirements USING btree (reqid, project_id, item_id, archive_id);


--
-- TOC entry 2552 (class 1259 OID 1314787)
-- Name: index_items_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_items_on_archive_id ON public.items USING btree (archive_id);


--
-- TOC entry 2553 (class 1259 OID 1314749)
-- Name: index_items_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_items_on_organization ON public.items USING btree (organization);


--
-- TOC entry 2554 (class 1259 OID 1314209)
-- Name: index_items_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_items_on_project_id ON public.items USING btree (project_id);


--
-- TOC entry 2774 (class 1259 OID 1315068)
-- Name: index_llr_mfs_on_low_level_requirement_id_and_model_file_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_llr_mfs_on_low_level_requirement_id_and_model_file_id ON public.llr_mfs USING btree (low_level_requirement_id, model_file_id);


--
-- TOC entry 2775 (class 1259 OID 1315069)
-- Name: index_llr_mfs_on_model_file_id_and_low_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_llr_mfs_on_model_file_id_and_low_level_requirement_id ON public.llr_mfs USING btree (model_file_id, low_level_requirement_id);


--
-- TOC entry 2686 (class 1259 OID 1314653)
-- Name: index_llr_scs_on_low_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_llr_scs_on_low_level_requirement_id ON public.llr_scs USING btree (low_level_requirement_id);


--
-- TOC entry 2687 (class 1259 OID 1314654)
-- Name: index_llr_scs_on_source_code_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_llr_scs_on_source_code_id ON public.llr_scs USING btree (source_code_id);


--
-- TOC entry 2751 (class 1259 OID 1314959)
-- Name: index_llr_tcs_on_low_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_llr_tcs_on_low_level_requirement_id ON public.llr_tcs USING btree (low_level_requirement_id);


--
-- TOC entry 2752 (class 1259 OID 1314960)
-- Name: index_llr_tcs_on_test_case_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_llr_tcs_on_test_case_id ON public.llr_tcs USING btree (test_case_id);


--
-- TOC entry 2749 (class 1259 OID 1314946)
-- Name: index_llr_tps_on_low_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_llr_tps_on_low_level_requirement_id ON public.llr_tps USING btree (low_level_requirement_id);


--
-- TOC entry 2750 (class 1259 OID 1314947)
-- Name: index_llr_tps_on_test_procedure_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_llr_tps_on_test_procedure_id ON public.llr_tps USING btree (test_procedure_id);


--
-- TOC entry 2584 (class 1259 OID 1315105)
-- Name: index_llrs_on_full_id_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_llrs_on_full_id_and_project_id_and_item_id ON public.low_level_requirements USING btree (full_id, project_id, item_id, archive_id);


--
-- TOC entry 2585 (class 1259 OID 1315104)
-- Name: index_llrs_on_reqid_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_llrs_on_reqid_and_project_id_and_item_id ON public.low_level_requirements USING btree (reqid, project_id, item_id, archive_id);


--
-- TOC entry 2586 (class 1259 OID 1314790)
-- Name: index_low_level_requirements_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_low_level_requirements_on_archive_id ON public.low_level_requirements USING btree (archive_id);


--
-- TOC entry 2587 (class 1259 OID 1315006)
-- Name: index_low_level_requirements_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_low_level_requirements_on_document_id ON public.low_level_requirements USING btree (document_id);


--
-- TOC entry 2588 (class 1259 OID 1314318)
-- Name: index_low_level_requirements_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_low_level_requirements_on_item_id ON public.low_level_requirements USING btree (item_id);


--
-- TOC entry 2589 (class 1259 OID 1315087)
-- Name: index_low_level_requirements_on_model_file_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_low_level_requirements_on_model_file_id ON public.low_level_requirements USING btree (model_file_id);


--
-- TOC entry 2590 (class 1259 OID 1314752)
-- Name: index_low_level_requirements_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_low_level_requirements_on_organization ON public.low_level_requirements USING btree (organization);


--
-- TOC entry 2591 (class 1259 OID 1314319)
-- Name: index_low_level_requirements_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_low_level_requirements_on_project_id ON public.low_level_requirements USING btree (project_id);


--
-- TOC entry 2763 (class 1259 OID 1315052)
-- Name: index_model_files_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_model_files_on_archive_id ON public.model_files USING btree (archive_id);


--
-- TOC entry 2764 (class 1259 OID 1315054)
-- Name: index_model_files_on_full_id_and_project_and_item_and_archive; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_model_files_on_full_id_and_project_and_item_and_archive ON public.model_files USING btree (full_id, project_id, item_id, archive_id);


--
-- TOC entry 2765 (class 1259 OID 1315051)
-- Name: index_model_files_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_model_files_on_item_id ON public.model_files USING btree (item_id);


--
-- TOC entry 2766 (class 1259 OID 1315053)
-- Name: index_model_files_on_model_and_project_and_item_and_archive; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_model_files_on_model_and_project_and_item_and_archive ON public.model_files USING btree (model_id, project_id, item_id, archive_id);


--
-- TOC entry 2767 (class 1259 OID 1315050)
-- Name: index_model_files_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_model_files_on_project_id ON public.model_files USING btree (project_id);


--
-- TOC entry 2662 (class 1259 OID 1314800)
-- Name: index_problem_report_attachments_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_attachments_on_archive_id ON public.problem_report_attachments USING btree (archive_id);


--
-- TOC entry 2663 (class 1259 OID 1314594)
-- Name: index_problem_report_attachments_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_attachments_on_item_id ON public.problem_report_attachments USING btree (item_id);


--
-- TOC entry 2664 (class 1259 OID 1314762)
-- Name: index_problem_report_attachments_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_attachments_on_organization ON public.problem_report_attachments USING btree (organization);


--
-- TOC entry 2665 (class 1259 OID 1314593)
-- Name: index_problem_report_attachments_on_problem_report_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_attachments_on_problem_report_id ON public.problem_report_attachments USING btree (problem_report_id);


--
-- TOC entry 2666 (class 1259 OID 1314595)
-- Name: index_problem_report_attachments_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_attachments_on_project_id ON public.problem_report_attachments USING btree (project_id);


--
-- TOC entry 2621 (class 1259 OID 1314796)
-- Name: index_problem_report_histories_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_histories_on_archive_id ON public.problem_report_histories USING btree (archive_id);


--
-- TOC entry 2622 (class 1259 OID 1314758)
-- Name: index_problem_report_histories_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_histories_on_organization ON public.problem_report_histories USING btree (organization);


--
-- TOC entry 2623 (class 1259 OID 1314448)
-- Name: index_problem_report_histories_on_problem_report_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_histories_on_problem_report_id ON public.problem_report_histories USING btree (problem_report_id);


--
-- TOC entry 2624 (class 1259 OID 1314447)
-- Name: index_problem_report_histories_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_report_histories_on_project_id ON public.problem_report_histories USING btree (project_id);


--
-- TOC entry 2615 (class 1259 OID 1314795)
-- Name: index_problem_reports_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_reports_on_archive_id ON public.problem_reports USING btree (archive_id);


--
-- TOC entry 2616 (class 1259 OID 1314425)
-- Name: index_problem_reports_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_reports_on_item_id ON public.problem_reports USING btree (item_id);


--
-- TOC entry 2617 (class 1259 OID 1314757)
-- Name: index_problem_reports_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_reports_on_organization ON public.problem_reports USING btree (organization);


--
-- TOC entry 2618 (class 1259 OID 1314424)
-- Name: index_problem_reports_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_problem_reports_on_project_id ON public.problem_reports USING btree (project_id);


--
-- TOC entry 2706 (class 1259 OID 1314773)
-- Name: index_project_accesses_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_project_accesses_on_organization ON public.project_accesses USING btree (organization);


--
-- TOC entry 2707 (class 1259 OID 1314745)
-- Name: index_project_accesses_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_project_accesses_on_project_id ON public.project_accesses USING btree (project_id);


--
-- TOC entry 2708 (class 1259 OID 1314744)
-- Name: index_project_accesses_on_user_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_project_accesses_on_user_id ON public.project_accesses USING btree (user_id);


--
-- TOC entry 2709 (class 1259 OID 1314746)
-- Name: index_project_accesses_on_user_id_and_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_project_accesses_on_user_id_and_project_id ON public.project_accesses USING btree (user_id, project_id);


--
-- TOC entry 2535 (class 1259 OID 1314785)
-- Name: index_projects_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_projects_on_archive_id ON public.projects USING btree (archive_id);


--
-- TOC entry 2536 (class 1259 OID 1314747)
-- Name: index_projects_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_projects_on_organization ON public.projects USING btree (organization);


--
-- TOC entry 2655 (class 1259 OID 1314799)
-- Name: index_review_attachments_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_review_attachments_on_archive_id ON public.review_attachments USING btree (archive_id);


--
-- TOC entry 2656 (class 1259 OID 1314565)
-- Name: index_review_attachments_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_review_attachments_on_item_id ON public.review_attachments USING btree (item_id);


--
-- TOC entry 2657 (class 1259 OID 1314761)
-- Name: index_review_attachments_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_review_attachments_on_organization ON public.review_attachments USING btree (organization);


--
-- TOC entry 2658 (class 1259 OID 1314566)
-- Name: index_review_attachments_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_review_attachments_on_project_id ON public.review_attachments USING btree (project_id);


--
-- TOC entry 2659 (class 1259 OID 1314564)
-- Name: index_review_attachments_on_review_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_review_attachments_on_review_id ON public.review_attachments USING btree (review_id);


--
-- TOC entry 2569 (class 1259 OID 1314792)
-- Name: index_reviews_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_reviews_on_archive_id ON public.reviews USING btree (archive_id);


--
-- TOC entry 2570 (class 1259 OID 1314263)
-- Name: index_reviews_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_reviews_on_item_id ON public.reviews USING btree (item_id);


--
-- TOC entry 2571 (class 1259 OID 1314754)
-- Name: index_reviews_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_reviews_on_organization ON public.reviews USING btree (organization);


--
-- TOC entry 2572 (class 1259 OID 1314264)
-- Name: index_reviews_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_reviews_on_project_id ON public.reviews USING btree (project_id);


--
-- TOC entry 2678 (class 1259 OID 1314801)
-- Name: index_source_codes_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_source_codes_on_archive_id ON public.source_codes USING btree (archive_id);


--
-- TOC entry 2679 (class 1259 OID 1315106)
-- Name: index_source_codes_on_codeid_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_source_codes_on_codeid_and_project_id_and_item_id ON public.source_codes USING btree (codeid, project_id, item_id, archive_id);


--
-- TOC entry 2680 (class 1259 OID 1315107)
-- Name: index_source_codes_on_full_id_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_source_codes_on_full_id_and_project_id_and_item_id ON public.source_codes USING btree (full_id, project_id, item_id, archive_id);


--
-- TOC entry 2681 (class 1259 OID 1314646)
-- Name: index_source_codes_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_source_codes_on_item_id ON public.source_codes USING btree (item_id);


--
-- TOC entry 2682 (class 1259 OID 1314768)
-- Name: index_source_codes_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_source_codes_on_organization ON public.source_codes USING btree (organization);


--
-- TOC entry 2683 (class 1259 OID 1314647)
-- Name: index_source_codes_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_source_codes_on_project_id ON public.source_codes USING btree (project_id);


--
-- TOC entry 2567 (class 1259 OID 1314239)
-- Name: index_sysreq_hlrs_on_high_level_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_sysreq_hlrs_on_high_level_requirement_id ON public.sysreq_hlrs USING btree (high_level_requirement_id);


--
-- TOC entry 2568 (class 1259 OID 1314238)
-- Name: index_sysreq_hlrs_on_system_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_sysreq_hlrs_on_system_requirement_id ON public.sysreq_hlrs USING btree (system_requirement_id);


--
-- TOC entry 2770 (class 1259 OID 1315059)
-- Name: index_sysreq_mfs_on_model_file_id_and_system_requirement_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_sysreq_mfs_on_model_file_id_and_system_requirement_id ON public.sysreq_mfs USING btree (model_file_id, system_requirement_id);


--
-- TOC entry 2771 (class 1259 OID 1315058)
-- Name: index_sysreq_mfs_on_system_requirement_id_and_model_file_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_sysreq_mfs_on_system_requirement_id_and_model_file_id ON public.sysreq_mfs USING btree (system_requirement_id, model_file_id);


--
-- TOC entry 2543 (class 1259 OID 1314786)
-- Name: index_system_requirements_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_system_requirements_on_archive_id ON public.system_requirements USING btree (archive_id);


--
-- TOC entry 2544 (class 1259 OID 1314994)
-- Name: index_system_requirements_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_system_requirements_on_document_id ON public.system_requirements USING btree (document_id);


--
-- TOC entry 2545 (class 1259 OID 1315101)
-- Name: index_system_requirements_on_full_id_and_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_system_requirements_on_full_id_and_project_id ON public.system_requirements USING btree (full_id, project_id, archive_id);


--
-- TOC entry 2546 (class 1259 OID 1315075)
-- Name: index_system_requirements_on_model_file_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_system_requirements_on_model_file_id ON public.system_requirements USING btree (model_file_id);


--
-- TOC entry 2547 (class 1259 OID 1314748)
-- Name: index_system_requirements_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_system_requirements_on_organization ON public.system_requirements USING btree (organization);


--
-- TOC entry 2548 (class 1259 OID 1314185)
-- Name: index_system_requirements_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_system_requirements_on_project_id ON public.system_requirements USING btree (project_id);


--
-- TOC entry 2549 (class 1259 OID 1315100)
-- Name: index_system_requirements_on_reqid_and_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_system_requirements_on_reqid_and_project_id ON public.system_requirements USING btree (reqid, project_id, archive_id);


--
-- TOC entry 2776 (class 1259 OID 1315074)
-- Name: index_tc_mfs_on_model_file_id_and_test_case_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_tc_mfs_on_model_file_id_and_test_case_id ON public.tc_mfs USING btree (model_file_id, test_case_id);


--
-- TOC entry 2777 (class 1259 OID 1315073)
-- Name: index_tc_mfs_on_test_case_id_and_model_file_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_tc_mfs_on_test_case_id_and_model_file_id ON public.tc_mfs USING btree (test_case_id, model_file_id);


--
-- TOC entry 2753 (class 1259 OID 1314961)
-- Name: index_tcs_tps_on_test_case_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_tcs_tps_on_test_case_id ON public.tcs_tps USING btree (test_case_id);


--
-- TOC entry 2754 (class 1259 OID 1314962)
-- Name: index_tcs_tps_on_test_procedure_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_tcs_tps_on_test_procedure_id ON public.tcs_tps USING btree (test_procedure_id);


--
-- TOC entry 2700 (class 1259 OID 1314772)
-- Name: index_template_checklist_items_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_template_checklist_items_on_organization ON public.template_checklist_items USING btree (organization);


--
-- TOC entry 2701 (class 1259 OID 1314717)
-- Name: index_template_checklist_items_on_template_checklist_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_template_checklist_items_on_template_checklist_id ON public.template_checklist_items USING btree (template_checklist_id);


--
-- TOC entry 2696 (class 1259 OID 1314771)
-- Name: index_template_checklists_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_template_checklists_on_organization ON public.template_checklists USING btree (organization);


--
-- TOC entry 2697 (class 1259 OID 1314700)
-- Name: index_template_checklists_on_template_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_template_checklists_on_template_id ON public.template_checklists USING btree (template_id);


--
-- TOC entry 2721 (class 1259 OID 1314837)
-- Name: index_template_documents_on_template_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_template_documents_on_template_id ON public.template_documents USING btree (template_id);


--
-- TOC entry 2693 (class 1259 OID 1314770)
-- Name: index_templates_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_templates_on_organization ON public.templates USING btree (organization);


--
-- TOC entry 2629 (class 1259 OID 1314797)
-- Name: index_test_cases_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_cases_on_archive_id ON public.test_cases USING btree (archive_id);


--
-- TOC entry 2630 (class 1259 OID 1315108)
-- Name: index_test_cases_on_caseid_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_test_cases_on_caseid_and_project_id_and_item_id ON public.test_cases USING btree (caseid, project_id, item_id, archive_id);


--
-- TOC entry 2631 (class 1259 OID 1315012)
-- Name: index_test_cases_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_cases_on_document_id ON public.test_cases USING btree (document_id);


--
-- TOC entry 2632 (class 1259 OID 1315109)
-- Name: index_test_cases_on_full_id_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_test_cases_on_full_id_and_project_id_and_item_id ON public.test_cases USING btree (full_id, project_id, item_id, archive_id);


--
-- TOC entry 2633 (class 1259 OID 1314475)
-- Name: index_test_cases_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_cases_on_item_id ON public.test_cases USING btree (item_id);


--
-- TOC entry 2634 (class 1259 OID 1315093)
-- Name: index_test_cases_on_model_file_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_cases_on_model_file_id ON public.test_cases USING btree (model_file_id);


--
-- TOC entry 2635 (class 1259 OID 1314759)
-- Name: index_test_cases_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_cases_on_organization ON public.test_cases USING btree (organization);


--
-- TOC entry 2636 (class 1259 OID 1314476)
-- Name: index_test_cases_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_cases_on_project_id ON public.test_cases USING btree (project_id);


--
-- TOC entry 2738 (class 1259 OID 1314934)
-- Name: index_test_procedures_on_archive_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_procedures_on_archive_id ON public.test_procedures USING btree (archive_id);


--
-- TOC entry 2739 (class 1259 OID 1315018)
-- Name: index_test_procedures_on_document_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_procedures_on_document_id ON public.test_procedures USING btree (document_id);


--
-- TOC entry 2740 (class 1259 OID 1315111)
-- Name: index_test_procedures_on_full_id_and_project_id_and_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_test_procedures_on_full_id_and_project_id_and_item_id ON public.test_procedures USING btree (full_id, project_id, item_id, archive_id);


--
-- TOC entry 2741 (class 1259 OID 1314932)
-- Name: index_test_procedures_on_item_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_procedures_on_item_id ON public.test_procedures USING btree (item_id);


--
-- TOC entry 2742 (class 1259 OID 1314937)
-- Name: index_test_procedures_on_organization; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_procedures_on_organization ON public.test_procedures USING btree (organization);


--
-- TOC entry 2743 (class 1259 OID 1315110)
-- Name: index_test_procedures_on_procedure_id_and_project_id_and_item; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_test_procedures_on_procedure_id_and_project_id_and_item ON public.test_procedures USING btree (procedure_id, project_id, item_id, archive_id);


--
-- TOC entry 2744 (class 1259 OID 1314933)
-- Name: index_test_procedures_on_project_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX index_test_procedures_on_project_id ON public.test_procedures USING btree (project_id);


--
-- TOC entry 2539 (class 1259 OID 1314167)
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- TOC entry 2540 (class 1259 OID 1314168)
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- TOC entry 2796 (class 2606 OID 1314338)
-- Name: document_comments fk_rails_0114bba210; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_comments
    ADD CONSTRAINT fk_rails_0114bba210 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2802 (class 2606 OID 1314395)
-- Name: action_items fk_rails_01bffc20bc; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.action_items
    ADD CONSTRAINT fk_rails_01bffc20bc FOREIGN KEY (review_id) REFERENCES public.reviews(id);


--
-- TOC entry 2778 (class 2606 OID 1314180)
-- Name: system_requirements fk_rails_03df235c72; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_requirements
    ADD CONSTRAINT fk_rails_03df235c72 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2836 (class 2606 OID 1315019)
-- Name: test_procedures fk_rails_06e00895cd; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_procedures
    ADD CONSTRAINT fk_rails_06e00895cd FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- TOC entry 2830 (class 2606 OID 1314862)
-- Name: code_checkmarks fk_rails_071444cc8b; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_checkmarks
    ADD CONSTRAINT fk_rails_071444cc8b FOREIGN KEY (source_code_id) REFERENCES public.source_codes(id);


--
-- TOC entry 2779 (class 2606 OID 1314995)
-- Name: system_requirements fk_rails_0c048466bf; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_requirements
    ADD CONSTRAINT fk_rails_0c048466bf FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- TOC entry 2823 (class 2606 OID 1314666)
-- Name: github_accesses fk_rails_0ff980fe24; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.github_accesses
    ADD CONSTRAINT fk_rails_0ff980fe24 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2798 (class 2606 OID 1314362)
-- Name: checklist_items fk_rails_127a48e629; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT fk_rails_127a48e629 FOREIGN KEY (review_id) REFERENCES public.reviews(id);


--
-- TOC entry 2783 (class 2606 OID 1314226)
-- Name: high_level_requirements fk_rails_13599503f5; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.high_level_requirements
    ADD CONSTRAINT fk_rails_13599503f5 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2815 (class 2606 OID 1314554)
-- Name: review_attachments fk_rails_139ca4745f; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.review_attachments
    ADD CONSTRAINT fk_rails_139ca4745f FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2801 (class 2606 OID 1314390)
-- Name: action_items fk_rails_17aeefee15; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.action_items
    ADD CONSTRAINT fk_rails_17aeefee15 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2825 (class 2606 OID 1314712)
-- Name: template_checklist_items fk_rails_18d858b850; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_checklist_items
    ADD CONSTRAINT fk_rails_18d858b850 FOREIGN KEY (template_checklist_id) REFERENCES public.template_checklists(id);


--
-- TOC entry 2786 (class 2606 OID 1314253)
-- Name: reviews fk_rails_1b37fb5a2a; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_1b37fb5a2a FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2833 (class 2606 OID 1314917)
-- Name: test_procedures fk_rails_325d5ccb3f; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_procedures
    ADD CONSTRAINT fk_rails_325d5ccb3f FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2782 (class 2606 OID 1314221)
-- Name: high_level_requirements fk_rails_3c14c94cdd; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.high_level_requirements
    ADD CONSTRAINT fk_rails_3c14c94cdd FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2791 (class 2606 OID 1314308)
-- Name: low_level_requirements fk_rails_3e1078c7ec; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.low_level_requirements
    ADD CONSTRAINT fk_rails_3e1078c7ec FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2812 (class 2606 OID 1314525)
-- Name: document_attachments fk_rails_40625c1aa9; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_attachments
    ADD CONSTRAINT fk_rails_40625c1aa9 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2799 (class 2606 OID 1314367)
-- Name: checklist_items fk_rails_4426ff7dda; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT fk_rails_4426ff7dda FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- TOC entry 2807 (class 2606 OID 1314465)
-- Name: test_cases fk_rails_48919d0211; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_cases
    ADD CONSTRAINT fk_rails_48919d0211 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2818 (class 2606 OID 1314583)
-- Name: problem_report_attachments fk_rails_4b0944849a; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_attachments
    ADD CONSTRAINT fk_rails_4b0944849a FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2804 (class 2606 OID 1314419)
-- Name: problem_reports fk_rails_51e983c2a9; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_reports
    ADD CONSTRAINT fk_rails_51e983c2a9 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2789 (class 2606 OID 1314282)
-- Name: documents fk_rails_55cfc1b0e0; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_55cfc1b0e0 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2790 (class 2606 OID 1314287)
-- Name: documents fk_rails_5669f9e902; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_5669f9e902 FOREIGN KEY (review_id) REFERENCES public.reviews(id);


--
-- TOC entry 2794 (class 2606 OID 1315088)
-- Name: low_level_requirements fk_rails_5a7f31ede8; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.low_level_requirements
    ADD CONSTRAINT fk_rails_5a7f31ede8 FOREIGN KEY (model_file_id) REFERENCES public.model_files(id);


--
-- TOC entry 2835 (class 2606 OID 1314927)
-- Name: test_procedures fk_rails_5e1b6c0454; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_procedures
    ADD CONSTRAINT fk_rails_5e1b6c0454 FOREIGN KEY (archive_id) REFERENCES public.archives(id);


--
-- TOC entry 2787 (class 2606 OID 1314258)
-- Name: reviews fk_rails_64798be025; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_64798be025 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2834 (class 2606 OID 1314922)
-- Name: test_procedures fk_rails_6d21768afd; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_procedures
    ADD CONSTRAINT fk_rails_6d21768afd FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2803 (class 2606 OID 1314414)
-- Name: problem_reports fk_rails_6f4bf76e66; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_reports
    ADD CONSTRAINT fk_rails_6f4bf76e66 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2805 (class 2606 OID 1314437)
-- Name: problem_report_histories fk_rails_75407905b5; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_histories
    ADD CONSTRAINT fk_rails_75407905b5 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2816 (class 2606 OID 1314559)
-- Name: review_attachments fk_rails_82e51f70f5; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.review_attachments
    ADD CONSTRAINT fk_rails_82e51f70f5 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2780 (class 2606 OID 1315076)
-- Name: system_requirements fk_rails_8473c1f92e; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_requirements
    ADD CONSTRAINT fk_rails_8473c1f92e FOREIGN KEY (model_file_id) REFERENCES public.model_files(id);


--
-- TOC entry 2832 (class 2606 OID 1314899)
-- Name: code_conditional_blocks fk_rails_8d5ef52c35; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_conditional_blocks
    ADD CONSTRAINT fk_rails_8d5ef52c35 FOREIGN KEY (source_code_id) REFERENCES public.source_codes(id);


--
-- TOC entry 2792 (class 2606 OID 1314313)
-- Name: low_level_requirements fk_rails_967f880115; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.low_level_requirements
    ADD CONSTRAINT fk_rails_967f880115 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2831 (class 2606 OID 1314881)
-- Name: code_checkmark_hits fk_rails_9ef1d05b37; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.code_checkmark_hits
    ADD CONSTRAINT fk_rails_9ef1d05b37 FOREIGN KEY (code_checkmark_id) REFERENCES public.code_checkmarks(id);


--
-- TOC entry 2788 (class 2606 OID 1314277)
-- Name: documents fk_rails_9fa64cfbd0; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_9fa64cfbd0 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2797 (class 2606 OID 1314343)
-- Name: document_comments fk_rails_a881c0c230; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_comments
    ADD CONSTRAINT fk_rails_a881c0c230 FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- TOC entry 2837 (class 2606 OID 1315035)
-- Name: model_files fk_rails_aa4be2d34e; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_files
    ADD CONSTRAINT fk_rails_aa4be2d34e FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2811 (class 2606 OID 1314520)
-- Name: document_attachments fk_rails_adb6722691; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_attachments
    ADD CONSTRAINT fk_rails_adb6722691 FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- TOC entry 2819 (class 2606 OID 1314588)
-- Name: problem_report_attachments fk_rails_ae965e8203; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_attachments
    ADD CONSTRAINT fk_rails_ae965e8203 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2784 (class 2606 OID 1315001)
-- Name: high_level_requirements fk_rails_b9efbc99e4; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.high_level_requirements
    ADD CONSTRAINT fk_rails_b9efbc99e4 FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- TOC entry 2785 (class 2606 OID 1315082)
-- Name: high_level_requirements fk_rails_ba58a61766; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.high_level_requirements
    ADD CONSTRAINT fk_rails_ba58a61766 FOREIGN KEY (model_file_id) REFERENCES public.model_files(id);


--
-- TOC entry 2839 (class 2606 OID 1315045)
-- Name: model_files fk_rails_bad3f27146; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_files
    ADD CONSTRAINT fk_rails_bad3f27146 FOREIGN KEY (archive_id) REFERENCES public.archives(id);


--
-- TOC entry 2827 (class 2606 OID 1314739)
-- Name: project_accesses fk_rails_c1f5110f20; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.project_accesses
    ADD CONSTRAINT fk_rails_c1f5110f20 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2828 (class 2606 OID 1314813)
-- Name: gitlab_accesses fk_rails_c84abe413d; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.gitlab_accesses
    ADD CONSTRAINT fk_rails_c84abe413d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2814 (class 2606 OID 1314549)
-- Name: review_attachments fk_rails_cbc178c9e0; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.review_attachments
    ADD CONSTRAINT fk_rails_cbc178c9e0 FOREIGN KEY (review_id) REFERENCES public.reviews(id);


--
-- TOC entry 2838 (class 2606 OID 1315040)
-- Name: model_files fk_rails_cca1d0384e; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_files
    ADD CONSTRAINT fk_rails_cca1d0384e FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2821 (class 2606 OID 1314636)
-- Name: source_codes fk_rails_ce1930f066; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.source_codes
    ADD CONSTRAINT fk_rails_ce1930f066 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2795 (class 2606 OID 1314333)
-- Name: document_comments fk_rails_d1750e9205; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_comments
    ADD CONSTRAINT fk_rails_d1750e9205 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2817 (class 2606 OID 1314578)
-- Name: problem_report_attachments fk_rails_d52169b522; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_attachments
    ADD CONSTRAINT fk_rails_d52169b522 FOREIGN KEY (problem_report_id) REFERENCES public.problem_reports(id);


--
-- TOC entry 2829 (class 2606 OID 1314832)
-- Name: template_documents fk_rails_d6f158e3d3; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_documents
    ADD CONSTRAINT fk_rails_d6f158e3d3 FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- TOC entry 2793 (class 2606 OID 1315007)
-- Name: low_level_requirements fk_rails_d71d9d50d0; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.low_level_requirements
    ADD CONSTRAINT fk_rails_d71d9d50d0 FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- TOC entry 2822 (class 2606 OID 1314641)
-- Name: source_codes fk_rails_d8bee796f5; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.source_codes
    ADD CONSTRAINT fk_rails_d8bee796f5 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2809 (class 2606 OID 1315013)
-- Name: test_cases fk_rails_da44429b51; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_cases
    ADD CONSTRAINT fk_rails_da44429b51 FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- TOC entry 2806 (class 2606 OID 1314442)
-- Name: problem_report_histories fk_rails_e4f9e911c5; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.problem_report_histories
    ADD CONSTRAINT fk_rails_e4f9e911c5 FOREIGN KEY (problem_report_id) REFERENCES public.problem_reports(id);


--
-- TOC entry 2808 (class 2606 OID 1314470)
-- Name: test_cases fk_rails_e55949e3b7; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_cases
    ADD CONSTRAINT fk_rails_e55949e3b7 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2826 (class 2606 OID 1314734)
-- Name: project_accesses fk_rails_e8995dcc4a; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.project_accesses
    ADD CONSTRAINT fk_rails_e8995dcc4a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2810 (class 2606 OID 1315094)
-- Name: test_cases fk_rails_ebec97f724; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.test_cases
    ADD CONSTRAINT fk_rails_ebec97f724 FOREIGN KEY (model_file_id) REFERENCES public.model_files(id);


--
-- TOC entry 2800 (class 2606 OID 1314385)
-- Name: action_items fk_rails_f097d82853; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.action_items
    ADD CONSTRAINT fk_rails_f097d82853 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 2820 (class 2606 OID 1314618)
-- Name: change_sessions fk_rails_f26b19ec33; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.change_sessions
    ADD CONSTRAINT fk_rails_f26b19ec33 FOREIGN KEY (data_change_id) REFERENCES public.data_changes(id);


--
-- TOC entry 2781 (class 2606 OID 1314204)
-- Name: items fk_rails_f6abf55b81; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_f6abf55b81 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 2824 (class 2606 OID 1314695)
-- Name: template_checklists fk_rails_fae91f0f42; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.template_checklists
    ADD CONSTRAINT fk_rails_fae91f0f42 FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- TOC entry 2813 (class 2606 OID 1314530)
-- Name: document_attachments fk_rails_fd46c66f47; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_attachments
    ADD CONSTRAINT fk_rails_fd46c66f47 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 3047 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2020-07-22 13:08:28 PDT

--
-- PostgreSQL database dump complete
--

