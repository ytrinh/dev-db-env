

CREATE TABLE test (
  test_id               uuid NOT NULL DEFAULT uuid_generate_v1mc(),
  data                  varchar(256),
  -- Keys
  CONSTRAINT test_pkey PRIMARY KEY (test_id)
);
